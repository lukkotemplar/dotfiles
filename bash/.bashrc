case $- in
    *i*) ;;
      *) return;;
esac
clear
command_not_found_handle() {
	echo "Bad command"
}
reboot() {
	:;
}
poweroff() {
	:;
}
print_prompt() {
    if [[ "$PWD" == "$HOME" ]]; then
        echo "HOME"
    elif [[ "$PWD" == "$HOME"* ]]; then
        echo "HOME/$(realpath --relative-to=$HOME .)"
    elif [[ "$PWD" == "/" ]]; then
        echo "ROOT"
    elif [[ "$PWD" == "/"* ]]; then
        if [[ "$PWD" == "/mnt/lukkotemplar" ]]; then
            echo "EXT"
        elif [[ "$PWD" == "/mnt/lukkotemplar"* ]]; then
            echo "USB/$(realpath --relative-to=/mnt/lukkotemplar .)"
        else
        echo "ROOT/$(realpath --relative-to=/ .)"
        fi
    fi
}
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
alias ls='ls -F'
if pgrep -x dwm >/dev/null 2>&1; then
    PS1='\[\e[37m\]\[\e[1m\]$(print_prompt)>\[\e[0m\]\[\e[1m\]' # Prompt for dwm
else
    PS1='$(print_prompt)>' # Prompt for tty
fi
export PATH="$HOME/.local/bin:$PATH" # PATH
export BROWSER='librewolf' # Change it to your preferred browser
export NOTES='obsidian' # Change it to your preferred botes app
