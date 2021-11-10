#!/usr/bin/env bash

choice=$(echo -e "Copy\nCrop\nFull" | dmenu -i -p "Chosse")

case $choice in
  Copy)
	import png:- | xclip -selection clipboard -t image/png
    ;;
  Crop)
	gnome-screenshot -a && espeak Area
    ;;
  Full)
	gnome-screenshot && espeak Full
    ;;
  *)
	espeak "Error "
    ;;
esac
