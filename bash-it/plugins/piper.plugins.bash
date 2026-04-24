#!/bin/bash

SCM_JJ="$(type -p "jj" || true)"
: "${JJ_EXE:=${SCM_JJ?}}"

SCM_CITC='citc'
SCM_CITC_CHAR='G3±'
SCM_CITC_DETACHED_CHAR='⌿'
SCM_CITC_AHEAD_CHAR="↑"
SCM_CITC_NON_UPLOADED_CHAR="⇧"
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
	elif [[ -x "${JJ_EXE-}" ]] && _bash-it-find-in-ancestor '.citc' > /dev/null; then
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

function cl_linkify() {
	local base_url="${1}"

	if [[ $base_url =~ ^@?(cl/[0-9]+) ]]; then
		base_url="${BASH_REMATCH[1]}"
		echo -n "\e]8;;http://${base_url}\a${1}\e]8;;\a"
	else
		echo -n "${1}"
	fi
}

function citc_prompt_vars() {
	local start=$EPOCHREALTIME
	local jj_query="$(jj log --no-graph -r p4head::@ -T '
if(current_working_copy,
  join(",",
    if(bookmarks.len() > 0,
      "@" ++ bookmarks.first(),
      if(parents.first().p4head() && empty,
        "cl/" ++ parents.first().submitted_change_number() ++ "(p4head)",
        if(parents.first().bookmarks().len() > 0,
          parents.first().bookmarks().first(),
          "cl/*"
        )
      )
    ),
    diff.files().len(),
    conflicted_files.len(),
  ),
  if(bookmarks.len() > 0,
    "-",
    if(p4head,
      "",
      "^"
    )
  )
)
')"
	if [[ "${CITC_BENCHMARK}" != "" ]]; then
		local duration="$(echo "scale=2; ($EPOCHREALTIME - $start)" | bc)s "
	fi
	local non_uploaded_ahead=$(echo "${jj_query}" |  tr -cd '^' | wc -c)
	local ahead=$(( $(echo "${jj_query}" |  tr -cd '-' | wc -c) + $non_uploaded_ahead ))
	jj_query=${jj_query//-/}
	jj_query=${jj_query//^/}
	IFS=',' read -r -a jj_query_array <<< "${duration},${jj_query}"

	local duration="${jj_query_array[0]}"
	local cl="${jj_query_array[1]}"
	local open_files="${jj_query_array[2]}"
	local unstaged_files="0"
	local conflicted_files="${jj_query_array[3]}"

	if [[ "${cl}" == "cl/*" ]]; then
		unstaged_files="${open_files}"
		open_files="0"
	fi

	SCM_BRANCH="$(basename $(jj workspace root))"

	if [[ "${ahead}" -gt 0 ]]; then
		SCM_BRANCH+="${SCM_CITC_AHEAD_BEHIND_PREFIX_CHAR}${SCM_CITC_AHEAD_CHAR}"
		SCM_BRANCH+="${ahead}"
	fi

	if [[ "${non_uploaded_ahead}" -gt 0 ]]; then
		SCM_BRANCH+="${SCM_CITC_AHEAD_BEHIND_PREFIX_CHAR}${SCM_CITC_NON_UPLOADED_CHAR}"
		SCM_BRANCH+="${non_uploaded_ahead}"
	fi

	if [[ "${open_files}" -gt 0 || "${unstaged_files}" -gt 0 || "${conflicted_files}" -gt 0 ]]; then
		SCM_DIRTY=1
		if [[ "${open_files}" -gt 0 ]]; then
			SCM_BRANCH+=" ${SCM_CITC_STAGED_CHAR}${open_files}" && SCM_DIRTY=3
		fi

		if [[ "${unstaged_files}" -gt 0 ]]; then
			SCM_BRANCH+=" ${SCM_CITC_UNSTAGED_CHAR}${unstaged_files}" && SCM_DIRTY=2
		fi

		if [[ "${conflicted_files}" -gt 0 ]]; then
			SCM_BRANCH+=" ${SCM_CITC_UNTRACKED_CHAR}${conflicted_files}" && SCM_DIRTY=1
		fi


		SCM_STATE="${CITC_THEME_PROMPT_DIRTY:-${SCM_THEME_PROMPT_DIRTY?}}"
	fi


	SCM_PREFIX="${CITC_THEME_PROMPT_PREFIX:-${SCM_THEME_PROMPT_PREFIX-}}"
	SCM_SUFFIX="${CITC_THEME_PROMPT_SUFFIX:-${SCM_THEME_PROMPT_SUFFIX-}}"

	SCM_CHANGE=" ${duration}$(cl_linkify ${cl})"
}

function citc_prompt_info() {
	citc_prompt_vars

	echo -ne "${SCM_PREFIX?}${SCM_BRANCH?}${SCM_CHANGE?}${SCM_STATE?}${SCM_SUFFIX?}"
}
