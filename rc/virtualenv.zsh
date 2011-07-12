# -*- sh -*-

# Virtualenv related functions
# Simplified version of virtualenvwrapper.
#  1. virtualenv works inside WORKON_HOME
#  2. workon allows to :
#       - switch to another environment
#       - deactivate an environment
#       - list available environments

(( $+commands[virtualenv] )) && {
    WORKON_HOME=${WORKON_HOME:-~/.virtualenvs}
    [[ -d $WORKON_HOME ]] || mkdir -p $WORKON_HOME

    virtualenv () {
	pushd $WORKON_HOME > /dev/null && {
	    command virtualenv "$@"
	    popd > /dev/null
	}
    }

    workon () {
	local env=$1
	# No parameters, list available environment
	[[ -n $env ]] || {
	    print "INFO: List of available environments:"
	    for env in $WORKON_HOME/*/bin/activate(.N:h:h:f); do
		print " - $env"
	    done
	    return 0
	}
	# Otherwise, switch to the environment
	[[ $env == "-" ]] || {
	    local activate
	    activate="$WORKON_HOME/$env/bin/activate"
	    [[ -d $WORKON_HOME/$env ]] || {
		print "ERROR: environment $env does not exist"
		return 2
	    }
	    [[ -f $activate ]] || {
		print "ERROR: environment $env does not have activate script"
		return 1
	    }
	}
	# If in another environment, call deactivate
	(( $+functions[deactivate] )) && {
	    deactivate
	}
	[[ $env == "-" ]] || {
	    local VIRTUAL_ENV_DISABLE_PROMPT=1
	    source $activate
	}
    }

    _vbe_add_prompt_virtualenv () {
	print -n '${VIRTUAL_ENV:+${PR_BLUE}(${PR_YELLOW}ve:${PR_NO_COLOUR}${VIRTUAL_ENV##*/}${PR_BLUE})'
	print -n '$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT}'
    }

}