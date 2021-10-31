#!/usr/bin/env bash

choice=$(echo -e "Shutdown\nLock\nSleep\nReboot\nQuit" | dmenu -i -p "Chosse")

case $choice in
  Shutdown)
	shutdown now
    ;;
  Lock)
	espeak "HOPE " && i3lock -c "#000033"
    ;;
  Sleep)
	i3lock -c "#000033" && systemctl suspend
    ;;
  Reboot)
	reboot
    ;;
  Quit)
	i3-msg exit
	;;
  *)
	espeak "Error "
    ;;
esac
