# Set file creation mask
umask 002

# # No core dumps
limit coredumpsize 0

# Terminal initialization
stty -ixon
ttyctl -f

# Make sure we know the username
if [[ -z "$USER" ]]
then
    USER=`logname`; export USER
fi

# Setup a default path
PATH=.:$HOME/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11R6/bin

# Setup a pager
PAGER=less; export PAGER
LESS=aceiMs; export LESS

# Use vi for editing
EDITOR=/usr/bin/vi; export EDITOR
VISUAL=/usr/bin/vi; export VISUAL

# Z-shell options
setopt ALL_EXPORT
setopt AUTO_CD
setopt AUTO_LIST
setopt AUTO_MENU
setopt CDABLE_VARS
setopt CORRECT
setopt CORRECT_ALL
setopt EXTENDED_GLOB
setopt HIST_IGNORE_DUPS
setopt HIST_NO_STORE
setopt LIST_AMBIGUOUS
setopt LIST_TYPES
setopt LONG_LIST_JOBS
setopt NO_BEEP
setopt NO_NOMATCH
setopt NOTIFY
setopt RC_EXPAND_PARAM
setopt SH_WORD_SPLIT

# Keep tramp happy
if [[ "$TERM" = "dumb" ]]
then
    unsetopt ZLE
fi

# History setup
HISTFILE=$HOME/.zshhistory
SAVEHIST=200
HISTSIZE=200

# Files to ignore when completing
fignore=( \~ \# .o )

# Set the prompt
if [[ "$TERM" == "xterm" ]]
then
    PROMPT="%{]2;%M%}%m [%~] %# "
else
    PROMPT="%m [%~] %# "
fi

# Set aliases
alias ls="ls -CFh"
alias df="df -h"
alias du="du -h"
alias mv="nocorrect mv"         # no spelling correction on mv
alias cp="nocorrect cp"         # no spelling correction on cp
alias mkdir="nocorrect mkdir"   # no spelling correction on mkdir
alias man="nocorrect man"	# no spelling correction on man
alias pg="less"
alias mailq="/usr/sbin/exim -bp"
alias runq="sudo /usr/sbin/exim -qq"
alias mailrm="sudo /usr/sbin/exim -Mrm"
alias mailedit="sudo /usr/sbin/exim -Meb"
alias mailfreeze="sudo /usr/sbin/exim -Mf"
alias mailthaw="sudo /usr/sbin/exim -Mt"

# ish type history list (zsh: ctrl-v key, emacs ctrl-q key)
bindkey "\eOA"  history-beginning-search-backward \
        "\e[A"  history-beginning-search-backward \
        "\eOB"  history-beginning-search-forward  \
        "\e[B"  history-beginning-search-forward  \
        "\eOU"  end-of-line                       \
        "\e[U"  end-of-line                       \
        "^A"    beginning-of-line                 \
        "^E"    end-of-line                       \
        "\eOV"  beginning-of-line                 \
        "\e[V"  beginning-of-line                 \
        "\eOD"  backward-char                     \
        "\e[D"  backward-char                     \
        "\eOC"  forward-char                      \
        "\e[C"  forward-char                      \
        "^F"    forward-word                      \
        "^B"    backward-word                     \
        "\e[2~" overwrite-mode                    \
        "^P"    push-line                         \
	"^K"	kill-line			  \
	"\e[3~"	delete-char

# Completion options
. $HOME/.zcomp

# Add the local functions to the function search path
fpath=($HOME/zshfuncs $fpath)

# Autoload all functions on the function search path
foreach file in $HOME/zshfuncs/*
do
    autoload `basename $file`
done
