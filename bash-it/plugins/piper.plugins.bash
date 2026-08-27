#!/bin/bash

SCM_JJ="$(type -p "jj" || true)"
: "${JJ_EXE:=${SCM_JJ?}}"

SCM_CITC='citc'
SCM_CITC_CHAR='G3±'
SCM_CITC_DETACHED_CHAR='⌿'
SCM_CITC_AHEAD_CHAR="↑"
SCM_CITC_NON_UPLOADED_CHAR="⇧"
SCM_CITC_BEHIND_CHAR="↓"
SCM_CITC_BEHIND_NON_UPLOADED_CHAR="⇩"
SCM_CITC_AHEAD_BEHIND_PREFIX_CHAR=" "
SCM_CITC_UNTRACKED_CHAR="?:"
SCM_CITC_UNSTAGED_CHAR="U:"
SCM_CITC_STAGED_CHAR="S:"
SCM_CITC_STASH_CHAR_PREFIX="{"
SCM_CITC_STASH_CHAR_SUFFIX="}"

function scm() {
	if [[ "${SCM_CHECK:-true}" == "false" ]]; then
		SCM="${SCM_NONE-NONE}"
	elif [[ -x "${GIT_EXE-}" ]] && _bash-it-find-in-ancestor '.git' > /dev/null; then
		SCM="${SCM_GIT?}"
	elif [[ -x "${JJ_EXE-}" ]] && ([[ "$PWD" == /google/src/cloud/* ]] || _bash-it-find-in-ancestor '.citc' > /dev/null); then
		SCM="${SCM_CITC?}"
	else
		SCM="${SCM_NONE-NONE}"
	fi
}

function scm_prompt_char() {
	if [[ -z "${SCM:-}" ]]; then
		scm
	fi

	case ${SCM?} in
		"${SCM_GIT?}")
			SCM_CHAR="${SCM_GIT_CHAR?}"
			;;
		"${SCM_CITC?}")
			SCM_CHAR="${SCM_CITC_CHAR?}"
			;;
		*)
			SCM_CHAR="${SCM_NONE_CHAR:-}"
			;;
	esac
}

function _citc_workspace_name() {
	if [[ "$PWD" =~ ^/google/src/cloud/[^/]+/([^/]+) ]]; then
		echo "${BASH_REMATCH[1]}"
	else
		local ws="$(jj workspace root 2>/dev/null)"
		echo "${ws##*/}"
	fi
}

function _update_citc_cache_async() {
	local ws_name="$1"
	local cwd="$2"
	local cache_file="/dev/shm/citc_prompt_${USER}_${ws_name}"
	local lock_file="/dev/shm/citc_prompt_${USER}_${ws_name}.lock"

	# Avoid spawning duplicate background jobs if one is already in flight
	if [[ -f "$lock_file" ]]; then
		local lock_age=$(( $(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || echo 0) ))
		if [[ $lock_age -lt 4 ]]; then
			return
		fi
	fi
	touch "$lock_file" 2>/dev/null

	(
		cd "$cwd" 2>/dev/null || exit
		local template='
if(current_working_copy,
  join(",",
    if(bookmarks.len() > 0,
      "@" ++ bookmarks.first().name(),
      if(parents.first().p4head() && empty,
        "cl/" ++ parents.first().submitted_change_number() ++ "(p4head)",
        if(parents.first().bookmarks().len() > 0,
          parents.first().bookmarks().first().name(),
          "cl/*"
        )
      )
    ),
    diff.files().len(),
    conflicted_files.len(),
  ),
  if(bookmarks.len() > 0,
    "-",
    if(p4head || p4base,
      "",
      "^"
    )
  )
)'
		local jj_query="$(jj log --no-graph -r "p4head::@" -T "${template}" 2>/dev/null)"
		local direction="up"
		if [[ -z "${jj_query}" ]]; then
			direction="down"
			jj_query="$(jj log --no-graph -r "p4base::@" -T "${template}" 2>/dev/null)"
		fi

		local tmp_caret="${jj_query//[^^]/}"
		local non_uploaded_ahead="${#tmp_caret}"
		local tmp_dash="${jj_query//[^-]/}"
		local ahead=$(( ${#tmp_dash} + non_uploaded_ahead ))
		jj_query="${jj_query//-/}"
		jj_query="${jj_query//^/}"

		IFS=',' read -r cl open_files conflicted_files <<< "${jj_query}"
		local unstaged_files="0"
		if [[ "${cl}" == "cl/*" ]]; then
			unstaged_files="${open_files}"
			open_files="0"
		fi

		local branch="${ws_name}"
		if [[ ${ahead} -gt 0 ]]; then
			if [[ "${direction}" == "up" ]]; then
				branch+="${SCM_CITC_AHEAD_BEHIND_PREFIX_CHAR}${SCM_CITC_AHEAD_CHAR}${ahead}"
			else
				branch+="${SCM_CITC_AHEAD_BEHIND_PREFIX_CHAR}${SCM_CITC_BEHIND_CHAR}${ahead}"
			fi
		fi

		if [[ ${non_uploaded_ahead} -gt 0 ]]; then
			if [[ "${direction}" == "up" ]]; then
				branch+="${SCM_CITC_AHEAD_BEHIND_PREFIX_CHAR}${SCM_CITC_NON_UPLOADED_CHAR}${non_uploaded_ahead}"
			else
				branch+="${SCM_CITC_AHEAD_BEHIND_PREFIX_CHAR}${SCM_CITC_BEHIND_NON_UPLOADED_CHAR}${non_uploaded_ahead}"
			fi
		fi

		local dirty=""
		local state=""
		if [[ ${open_files:-0} -gt 0 || ${unstaged_files:-0} -gt 0 || ${conflicted_files:-0} -gt 0 ]]; then
			if [[ ${open_files:-0} -gt 0 ]]; then
				branch+=" ${SCM_CITC_STAGED_CHAR}${open_files}"
				dirty=3
			fi
			if [[ ${unstaged_files:-0} -gt 0 ]]; then
				branch+=" ${SCM_CITC_UNSTAGED_CHAR}${unstaged_files}"
				dirty=2
			fi
			if [[ ${conflicted_files:-0} -gt 0 ]]; then
				branch+=" ${SCM_CITC_UNTRACKED_CHAR}${conflicted_files}"
				dirty=1
			fi
			state="*"
		fi

		local link=""
		if [[ $cl =~ ^@?(cl/[0-9]+)\((p4head|p4base)\) ]]; then
			local base_url="${BASH_REMATCH[1]}"
			local p4=" (${BASH_REMATCH[2]})"
			link=" http://${base_url}${p4}"
		elif [[ -n "${cl}" ]]; then
			link=" http://${cl}"
		fi

		echo "${branch}|${link}|${dirty}|${state}" > "${cache_file}.tmp" 2>/dev/null
		mv "${cache_file}.tmp" "${cache_file}" 2>/dev/null
		rm -f "$lock_file" 2>/dev/null
	) &>/dev/null &
	disown 2>/dev/null
}

function citc_prompt_vars() {
	local ws_name="$(_citc_workspace_name)"
	local cache_file="/dev/shm/citc_prompt_${USER}_${ws_name}"

	if [[ -f "$cache_file" ]]; then
		IFS="|" read -r SCM_BRANCH SCM_CHANGE SCM_DIRTY SCM_STATE < "$cache_file"
		_update_citc_cache_async "$ws_name" "$PWD"
	else
		SCM_BRANCH="$ws_name"
		SCM_CHANGE=""
		SCM_DIRTY=""
		SCM_STATE=""
		_update_citc_cache_async "$ws_name" "$PWD"
	fi

	SCM_PREFIX="${CITC_THEME_PROMPT_PREFIX:-${SCM_THEME_PROMPT_PREFIX:-}}"
	SCM_SUFFIX="${CITC_THEME_PROMPT_SUFFIX:-${SCM_THEME_PROMPT_SUFFIX:-}}"
	if [[ -n "$SCM_STATE" ]]; then
		SCM_STATE="${CITC_THEME_PROMPT_DIRTY:-${SCM_THEME_PROMPT_DIRTY:-*}}"
	fi
}

function citc_prompt_info() {
	citc_prompt_vars
	echo -ne "${SCM_PREFIX:-}${SCM_BRANCH:-}${SCM_CHANGE:-}${SCM_STATE:-}${SCM_SUFFIX:-}"
}
