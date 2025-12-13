#!/bin/bash

SCM_CITC="citc"

function _p4-opened {
	echo ""
}

function scm() {
	if [[ "${SCM_CHECK:-true}" == "false" ]]; then
		SCM="${SCM_NONE-NONE}"
	elif [[ -x "${GIT_EXE-}" ]] && _bash-it-find-in-ancestor '.git' > /dev/null; then
		SCM="${SCM_GIT?}"
	elif [[ -x "${GIT_EXE-}" ]] && _bash-it-find-in-ancestor '.citc' > /dev/null; then
		SCM="${SCM_CITC?}"
	else
		SCM="${SCM_NONE-NONE}"
	fi
}


