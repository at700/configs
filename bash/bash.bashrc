#------------------------------------------------------------#
# Author: Aman Tiwari                                        #
# Last Modified: 04-07-2025                                  #
# Description: My custom bashrc                              #
#------------------------------------------------------------#

#---- If not running interactively, don't do anything
if [[ $- != *i* ]] || [[ $USER = drop ]]; then
  return
fi

#---- Add local PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  PATH="$HOME/.local/bin:$PATH"
fi

#---- Enable bash completion in non-posix shell
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

#---- History
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
HISTIGNORE='&:[ ]*:exit:ls:cd'
HISTTIMEFORMAT="%F %T "
shopt -s histappend

#---- Check window size after each command
shopt -s checkwinsize

#---- Set default editor
export EDITOR='vim'
export VISUAL='vim'

#---- Disable pager globally for systemd tools
export SYSTEMD_PAGER=

#---- Set term
export TERM=xterm-256color

#---- Fastfetch
if command -v fastfetch > /dev/null && [[ -z $TMUX$NVIM$KATE_PID && $TERM_PROGRAM != vscode ]]; then
  fastfetch
fi

#---- Shell prompt
if [[ "$EUID" -eq 0 ]]; then
  #---- root user
  PS1="\[\e]0;\u@\h: \w\a\]\[\033[38;5;209m\]┌──(\[\033[38;0;31m\]\u\[\033[38;5;209m\]:\[\033[38;0;31m\]\h\[\033[38;5;209m\])-[\[\033[0m\]\w\[\033[38;5;209m\]]\n\[\033[38;5;209m\]└─\[\033[38;0;31m\]$ \[\033[0m\]"
elif [[ $PATH =~ mobaxterm ]]; then
  #---- MobaXterm
  PS1="\[\e]0;mobaxterm: \w\a\]\[\033[38;5;209m\]┌──(\[\033[38;1;33m\]mobaxterm\[\033[38;5;209m\])-[\[\033[0m\]\w\[\033[38;5;209m\]]\n\[\033[38;5;209m\]└─\[\033[38;1;33m\]$ \[\033[0m\]"
elif [[ $(echo $0) == sh ]]; then
  #---- sh shel
  if [[ "$EUID" -eq 0 ]]; then
    #---- root sh
    PS1="\[\e]0;\u@\h: \w\a\]\[\033[38;5;209m\](\[\033[38;0;31m\]\u\[\033[38;5;209m\]:\[\033[38;0;31m\]\h\[\033[38;5;209m\])-[\[\033[0m\]\w\[\033[38;5;209m\]]\n\[\033[38;5;209m\]\[\033[38;0;31m\]$ \[\033[0m\]"
  else
    #---- non-root sh
    PS1="\[\e]0;\u@\h: \w\a\]\[\033[38;5;209m\](\[\033[38;5;141m\]\u\[\033[38;5;209m\]:\[\033[38;5;105m\]\h\[\033[38;5;209m\])-[\[\033[0m\]\w\[\033[38;5;209m\]]\n\[\033[38;5;209m\]\[\033[38;5;141m\]$ \[\033[0m\]"
  fi
else
  #---- Non-root users
  PS1="\[\e]0;\u@\h: \w\a\]\[\033[38;5;209m\]┌──(\[\033[38;5;141m\]\u\[\033[38;5;209m\]:\[\033[38;5;105m\]\h\[\033[38;5;209m\])-[\[\033[0m\]\w\[\033[38;5;209m\]]\n\[\033[38;5;209m\]└─\[\033[38;5;141m\]$ \[\033[0m\]"
fi

PROMPT_COMMAND="history -a; echo"

#---- Aliases
alias grep="grep --color=always"
alias ls="\ls --color=always"
alias ll="\ls -lh --color=always"
alias la="\ls -A --color=always"
alias lla="\ls -lAh --color=always"
alias l="\ls -CF --color=always"
alias tree="tree -C"
alias watch="watch -ct"

#---- WSL specific aliases
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
  alias ls="\ls --color=always 2>/dev/null | grep -vE '\?|\$RECYCLE\.BIN|System Volume Information'"
  alias ll="\ls -lh --color=always 2>/dev/null | grep -vE '\?|\$RECYCLE\.BIN|System Volume Information'"
  alias la="\ls -A --color=always 2>/dev/null | grep -vE '\?|\$RECYCLE\.BIN|System Volume Information'"
  alias lla="\ls -lAh --color=always 2>/dev/null | grep -vE '\?|\$RECYCLE\.BIN|System Volume Information'"
  alias l="\ls -CF --color=always 2>/dev/null | grep -vE '\?|\$RECYCLE\.BIN|System Volume Information'"
fi

#---- Functions
rcopy() {
  local SRC="$1"
  local DST="$2"
  rsync -a --info=progress2 --no-i-r "${@:3}" "$SRC" "$DST"
}

gpush() {
  git add .
  git commit -m "${1:-$(date -I)}"
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
}

gbackup() {
  local FILE="$1"
  sudo setfacl -m u:aman:rw $FILE
  ln $FILE
}
