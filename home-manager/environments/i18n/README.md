# NOTE: fcitx 5 work in gnome ubuntu but not work in i3wm ubuntu
- add `.xprofile`
```sh
export XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus
```
- reload `fcitx5 -rd`
