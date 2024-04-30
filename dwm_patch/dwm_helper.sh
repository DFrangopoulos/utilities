#!/bin/bash


get_battery()
{
	dwm_battery="$(echo "$(cat /sys/class/power_supply/BAT0/charge_now)*100/$(cat /sys/class/power_supply/BAT0/charge_full)" | bc)%"
}

get_layout()
{
	dwm_layout="$(setxkbmap -query | grep layout | cut -d":" -f2 | tr -d ' ')"
}

dwm_toggle_layout()
{
	get_layout
	if [ "$dwm_layout" != "gb" ]; then
		setxkbmap gb
	else
		setxkbmap -layout gr,gb
	fi
	dwm_status
}
get_audio()
{
	amixer get Master | grep -E "^  Front" -m1 | fgrep -q '[off]'
	if [ $? -eq 0 ]; then
		dwm_muted="muted"
	else
		dwm_muted="on"
	fi
}

get_audio_level()
{
	local audio_lvl="$(amixer get Master | grep "Front Right:" | sed -r -e 's/.*\[([0-9]+)%\].*/\1/' -e 's/[^0-9]//g')"

	get_audio

	if [ "$dwm_muted" = "muted" ] || [ "$audio_lvl" -eq 0 ]; then
		dwm_audio_lvl="[-MUT-]"
	else
		case "$((${audio_lvl}/20))" in
			"0")
				dwm_audio_lvl="[+----]"
			;;
			"1")
				dwm_audio_lvl="[++---]"
			;;
			"2")
				dwm_audio_lvl="[+++--]"
			;;
			"3")
				dwm_audio_lvl="[++++-]"
			;;
			"4" | "5")
				dwm_audio_lvl="[+++++]"
			;;
			*)
				dwm_audio_lvl="[-ERR-]"
			;;
		esac
	fi
}

get_date()
{
	dwm_date_time="$(date +"%F %R")"
}

dwm_cycle_bg()
{
	ls /usr/local/share/wallpapers/*.jp* | shuf -n1 | xargs feh --bg-scale
}

dwm_status()
{
	get_battery
	get_audio
	get_audio_level
	get_date
	get_layout

	xsetroot -name "$dwm_date_time $dwm_battery $dwm_layout $dwm_audio_lvl"
}

dwm_vol_up()
{
	amixer set Master 5%+
	dwm_status
}

dwm_vol_down()
{
	amixer set Master 5%-
	dwm_status
}

dwm_mute()
{
	#Toggle Mute
	amixer set Master toggle >/dev/null 2>&1
	#Trigger DWM Status Update
	dwm_status
}

dwm_toggle_hdmi()
{
	local current="$(/usr/bin/xrandr | grep -E " connected (primary )?[1-9]+" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")"
	if [ "$current" = "eDP-1" ]; then
		/usr/bin/xrandr --output eDP-1 --off
		/usr/bin/xrandr --output HDMI-1 --auto
	else
		/usr/bin/xrandr --output HDMI-1 --off
		/usr/bin/xrandr --output eDP-1 --auto
	fi
}

dwm_set_brightness()
{
	local current=$(/usr/bin/xrandr --verbose | grep -i "brightness"| sed 's/ //g' | cut -d":" -f2)

	if [ -z "$current" ] || [ -z "$1" ] ;then
		return
	fi

	if [ "$1" = "dec" ]; then
			new=$(bc <<< "${current}-0.1")
	elif [ "$1" = "inc" ]; then
			new=$(bc <<< "${current}+0.1")
	fi

	valid=$(bc <<<"${new} > 0 && ${new} <= 1")

	if [ "$valid" -eq 1 ];then
		  /usr/bin/xrandr --output eDP-1 --brightness $new
	fi
}

##MAIN
case "$1" in

	"-status")
		dwm_status
	;;

	"-toggle_mute")
		dwm_mute
	;;

	"-toggle_layout")
		dwm_toggle_layout
	;;

	"-screen")
		dwm_toggle_hdmi
	;;

	"-bright_up")
		dwm_set_brightness inc
	;;

	"-bright_down")
		dwm_set_brightness dec
	;;

	"-cycle_bg")
		dwm_cycle_bg
	;;

	"-vol_up")
		dwm_vol_up
	;;

	"-vol_down")
		dwm_vol_down
	;;

	*)
		echo "Invalid"!
	;;
esac
