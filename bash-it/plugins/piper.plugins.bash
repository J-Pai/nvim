#!/bin/bash

SCM_JJ="$(type -p "jj" || true)"
: "${JJ_EXE:=${SCM_JJ?}}"

SCM_CITC='citc'
SCM_CITC_CHAR='G3±'
SCM_CITC_DETACHED_CHAR='⌿'
SCM_CITC_AHEAD_CHAR="↑"
SCM_CITC_BEHIND_CHAR="↓"
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

function citc_prompt_vars() {
	local clickable_prefix="\e]8;;http://"
	local clickable_separator="\a"
	local clickable_suffix="\e]8;;"
	local jj_vars=$(jj log\
		--no-graph \
		-r @ \
		-T \
		"join(',', bookmarks,parents.first().bookmarks())")
	IFS="," read -ra jj_vars_array <<< "${jj_vars}"
	SCM_BRANCH="$(basename $(jj workspace root))"
	SCM_CHANGE=" ${clickable_prefix}${jj_vars_array[1]}${clickable_separator}${jj_vars_array[1]}${clickable_suffix}${clickable_separator}"
	SCM_DIRTY=2
	SCM_STATE="${CITC_THEME_PROMPT_CLEAN:-${SCM_THEME_PROMPT_CLEAN:-}}"
	SCM_PREFIX="${CITC_THEME_PROMPT_PREFIX:-${SCM_THEME_PROMPT_PREFIX-}}"
	SCM_SUFFIX="${CITC_THEME_PROMPT_SUFFIX:-${SCM_THEME_PROMPT_SUFFIX-}}"
}

function citc_prompt_info() {
	citc_prompt_vars
	echo -ne "${SCM_PREFIX?}${SCM_BRANCH?}:${SCM_CHANGE?}${SCM_STATE?}${SCM_SUFFIX?}"
}
