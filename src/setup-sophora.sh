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

SOPHORA_VERSIONS=( "GNOME Alpha" )
SOPHORA_STAGES=( "stage4-sophora-gnome-alpha.tar.xz" )
SOPHORA_STAGES_LOCATION=( "/some/where|https://dl.net.fr/some/were" )

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
    case `exit_box 3>&2 2>&1 1>&3` in
        1) echo "reboot";;
        2) echo "exit";;
        3) echo "poweroff";;
    esac
    
    exit
}


prepare() {
    #bash /etc/sophora/prepare.sh
    sleep 2
    return 0
}


prepare_failed() {
    prepare_failed_box
    exit_menu
}


select_sophora_version() {
    sophora_version_choices=()
    local sophora_version
    local spacer=$(repeat 10 " ")
    
    for key in "${!SOPHORA_VERSIONS[@]}"; do
        if [[ "${SOPHORA_VERSIONS[@]}" == "GNOME Alpha" ]]; then
            sophora_version_choices+=("${SOPHORA_VERSIONS[$key]}" "$spacer" "on")
            continue
        fi

        sophora_version_choices+=("${SOPHORA_VERSIONS[$key]}" "$spacer" "off")
    done
    
    sophora_version="$(select_sophora_version_box 3>&2 2>&1 1>&3)"
}

select_sophora_version_box() {
    local choices=($@)
    local title=`eval_gettext "Select Sophora version"`
    local text=`eval_gettext "Choose the Sophora stage to install"`
    
    dialog --title "$title" --radiolist "\n$text" 50 50 10 "${sophora_version_choices[@]}"
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


important_sophora_is_alpha_box() {
    local title=`eval_gettext "Important note!"`
    local text=`eval_gettext "Please note that Sophora Linux is still in alpha.
Please do not use it as your main operating system as things can break.

If you understand the risks, please continue."`
    
    dialog --title "\Z1\Zb$title\Zn" --no-label "Exit" --yes-label "Continue" \
    --colors --yesno "\n$text" 50 50
}


important_installer_is_alpha_box() {
    local title=`eval_gettext "Important note!"`
    local text=`eval_gettext "Please note that Sophora Linux install scripts \
are still in alpha. Unexpected things can append during the installation \
process.

Please do not use it on your main machine

If you understand the risks, please continue."`
    
    dialog --title "\Z1\Zb$title\Zn" --no-label "Exit" --yes-label "Continue" \
    --colors --yesno "\n$text" 50 50
}


prepare_box() {
    local title=`eval_gettext "Prepare the install"`
    local text=`eval_gettext "Please wait until basic preparations are \
finished..."`
    
    dialog --title "$title" --infobox "\n$text" 50 50
}


prepare_finished_box() {
    local title=`eval_gettext "Prepare the install"`
    local text=`eval_gettext "Preparations finished."`
    
    dialog --title "$title" --msgbox "\n$text" 50 50
}


prepare_failed_box() {
    local title=`eval_gettext "Prepare the install"`
    local text_failed=`eval_gettext "Preparations failed!"`
    local text_exit=`eval_gettext "Exiting."`
    
    dialog --title "$title" --colors --msgbox \
    "\n\Z1\Zb\Zr$text_failed\Zn\n\n$text_exit" 50 50
}



main() {
    case $page in
        0) welcome_box && page=$((page+1)) || exit_menu;;

        1) important_sophora_is_alpha_box && page=$((page+1)) || exit_menu;;
        
        2) important_installer_is_alpha_box && page=$((page+1))|| exit_menu;;
        
        3) prepare_box && page=$((page+1));;

        4) prepare && prepare_finished_box && page=$((page+1)) || prepare_failed;;
        
        5) select_sophora_version && page=$((page+1)) || exit_menu;;
        
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
