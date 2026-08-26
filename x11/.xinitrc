setxkbmap es
xsetroot -solid "#000000"
xset s off
xset -dpms
unclutter --timeout 1 --jitter 5 &
~/.local/bin/dwm-status &
kitty &
exec dwm
