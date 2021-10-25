# Z-shell options
setopt ALL_EXPORT
setopt AUTO_CD
setopt AUTO_LIST
setopt AUTO_MENU
setopt CDABLE_VARS
setopt CORRECT
setopt CORRECT_ALL
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt LIST_AMBIGUOUS
setopt LIST_TYPES
setopt LONG_LIST_JOBS
setopt NO_BEEP
setopt NO_NOMATCH
setopt NOTIFY
setopt PROMPT_SUBST
setopt PUSHD_SILENT
setopt SH_WORD_SPLIT

# Disable bracketed paste mode
unset zle_bracketed_paste

# Keep tramp happy
if [[ "$TERM" = "dumb" ]]
then
    unsetopt PROMPT_SP
    unsetopt PROMPT_CR
    unsetopt ZLE
fi

# Fallback to a more basic terminal type if necessary
if [[ -z "${terminfo[cols]}" ]]
then
    case "$TERM" in
        xterm*) TERM="xterm";;
    esac
fi

# Lock the terminal
ttyctl -f

# Make sure we know the username
if [[ -z "$USER" ]]
then
    USER="$(id -un)"; export USER
fi

# Setup a default path
PATH=".:${HOME}/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin"

# Setup a pager
PAGER="less"; export PAGER
LESS="aceiMRs"; export LESS

# Use vi for editing
EDITOR=/usr/bin/vi; export EDITOR
VISUAL=/usr/bin/vi; export VISUAL

# History setup
HISTFILE=$HOME/.zshhistory
SAVEHIST=1000
HISTSIZE=1500

# Ignore certain files when doing expansion
fignore=( \~ \# .o )

# Set the prompt
case "$TERM" in
    xterm*) PROMPT="%{]0;\${ENVIRONMENT:+\${ENVIRONMENT} on} %M%}%m [%~] %# ";;
    screen*) PROMPT="%{k\${ENVIRONMENT:+\${ENVIRONMENT} on} %M\%}%m [%~] %# ";;
    *) PROMPT="%m [%~] %# ";;
esac

# Configure directory colours
eval "$(/usr/bin/dircolors --sh ${HOME}/.dir_colors)"

# Setup aliases
alias ls="ls -CFhv --color=auto"
alias df="df -h"
alias du="du -h"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias cd="nocorrect cd"         # no spelling correction on cd
alias mv="nocorrect mv"         # no spelling correction on mv
alias cp="nocorrect cp"         # no spelling correction on cp
alias mkdir="nocorrect mkdir"   # no spelling correction on mkdir
alias man="nocorrect man"	# no spelling correction on man
alias pg="less"

# Select the emacs key map
bindkey -A emacs main

# Bind various keys - hard code xterm bindings to match linux xterms
case "$TERM" in
    dumb)
        ;;
    xterm*)
        bindkey "^[OA" history-beginning-search-backward
        bindkey "^[[A" history-beginning-search-backward
        bindkey "^[OB" history-beginning-search-forward
        bindkey "^[[B" history-beginning-search-forward
        bindkey "^[OH" beginning-of-line
        bindkey "^[OF" end-of-line
        bindkey "^[[2~" overwrite-mode
        bindkey "^[[3~" delete-char;;
    *)
        bindkey "${terminfo[kcuu1]}" history-beginning-search-backward
        bindkey "^[[A" history-beginning-search-backward
        bindkey "${terminfo[kcud1]}" history-beginning-search-forward
        bindkey "^[[B" history-beginning-search-forward
        bindkey "${terminfo[khome]}" beginning-of-line
        bindkey "${terminfo[kend]}" end-of-line
        bindkey "${terminfo[kich1]}" overwrite-mode
        bindkey "${terminfo[kdch1]}" delete-char;;
esac

# Configure completion
zstyle ":completion:*" completer _complete _approximate
zstyle ":completion:*" format "Completing %d"
zstyle ":completion:*" group-name ""
zstyle ":completion:*" menu select=long
zstyle ":completion:*" rehash true
zstyle ":completion:*" select-prompt "%SScrolling active: current selection at %p%s"

# Enable completion
autoload -U compinit
compinit

# Autoload all local functions
autoload ${HOME}/zshfuncs/*(:t)
