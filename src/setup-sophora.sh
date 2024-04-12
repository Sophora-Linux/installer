#!/usr/bin/env bash
# setup-sophora
# Copyright (C) 2022 Wamuu Sudo (Orchid Linux)
#               2022 Yannick Defais [Chevek] (Orchid Linux)
#               2022 Crystal (Orchid Linux)
#               2022 Babilinx (Orchid Linux)
#               2024 Babilinx <babilinx.evx1o@simplelogin.com> (Sophora Linux)
# This program is distributed under the terms of the GNU General Public License
# version 3. See <https://gnu.org/licenses/> for more.

source /usr/bin/gettext.sh
export TEXTDOMAIN="setup-sophora"


page=0


# Credit: https://www.cyberciti.biz/faq/repeat-a-character-in-bash-script-under-linux-unix/
repeat(){
	local start=1
	local end=${1:-80}
	local str="${2:-=}"
	local range=$(seq $start $end)
	for i in $range ; do echo -n "${str}"; done
}


exit_menu() {
    exit_box 2> /tmp/dialog_input
    case `cat /tmp/dialog_input` in
        1) echo "reboot";;
        2) echo "exit";;
        3) echo "poweroff";;
    esac
    
    exit
}


exit_box() {
    local title=`eval_gettext "Exit install"`
    local menu_msg=`eval_gettext "Select what to do"`
    local reboot_msg=`eval_gettext "Reboot computer"`
    local exit_msg=`eval_gettext "Exit setup-sophora"`
    local poweroff_msg=`eval_gettext "Poweroff computer"`
    
    dialog --title "$title" --no-cancel --menu "\n$menu_msg" 50 50 10 1 \
    "$reboot_msg" 2 "$exit_msg" 3 "$poweroff_msg"
}


welcome_box() {
    local title=`eval_gettext "Welcome to Sophora Linux installer"`
    local text=`eval_gettext "This script will let you configure and install \
Sophora Linux. Please be careful as you can delete important data!

Sophora Linux team will not take the responsibility if you lose data!"`
    
    dialog --title "$title" --no-label "Exit" --yes-label "Continue" --yesno "\n$text" 50 50
}


main() {
    case $page in
        0) welcome_box && page=$((page+1)) || exit_menu;;
        
        *) exit;;
    esac
}




if [ "$EUID" -ne 0 ]; then
    eval_gettext "This program needs root rights!"; echo
    #exit 1
fi


while true; do
    main
done
