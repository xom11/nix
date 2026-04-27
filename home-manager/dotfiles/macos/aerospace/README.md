### A note on mission control
```bash
defaults write com.apple.dock expose-group-apps -bool true && killall Dock
```
### Move windows by dragging any part of the window
```bash
defaults write -g NSWindowShouldDragOnGesture -bool true
```
Now, you can move windows by holding ctrl + cmd and dragging any part of the window (not necessarily the window title)