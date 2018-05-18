# -*- sh -*-

# Setup EDITOR
() {
    local -a editors
    local editor
    editors=(
        # Don't use "emacs" as it could be an alternative to something else (like jove)
	"emacs25 -nw ${(%):-%(!.-q.)} --eval='(global-font-lock-mode 1) (setq make-backup-files nil)'" # emacs
	"emacs24 -nw ${(%):-%(!.-q.)} --eval='(global-font-lock-mode 1) (setq make-backup-files nil)'" # emacs
	"emacs23 -nw ${(%):-%(!.-q.)} --eval='(global-font-lock-mode 1) (setq make-backup-files nil)'" # emacs
        "mg -n"           # emacs clone (make it not create backup files)
        "jove"            # Another emacs clone (don't create backup files by default)
	"zile" "jed"      # Other emacs clone (create backup files by default)
	"vim" "vi"	  # vi
	"editor")	  # fallback
    for editor in $editors; do
	(( $+commands[$editor[(w)1]] )) && {
	    # Some programs may not like to have arguments
	    if [[ $editor == *\ * ]]; then
		export EDITOR=$ZSH/run/u/$HOST-$UID/editor
		cat <<EOF > $EDITOR
#!/bin/sh
exec $editor "\$@"
EOF
		chmod +x $EDITOR
	    else
		export EDITOR=$editor
	    fi
	    break
	}
    done
    [[ -z $EDITOR ]] || {
        alias e=$EDITOR
        # Maybe use emacsclient?
        [[ $editor == emacs* ]] && (( $+commands[emacsclient] )) && {
	    export ALTERNATE_EDITOR=$EDITOR
            for editor in "emacsclient.${editor[(w)1]}" "emacsclient"; do
                (( $+commands[$editor] )) && break
            done
            export EDITOR=$ZSH/run/u/$HOST-$UID/editor-ec
            cat <<EOF > $EDITOR
#!/bin/zsh
exec $editor \${=\${DISPLAY:+}--t -c} "\$@"
EOF
            chmod +x $EDITOR
	    alias e="$editor "'${=${DISPLAY:+-n}:--t -c}'
        }
    }

}

unset VISUAL
