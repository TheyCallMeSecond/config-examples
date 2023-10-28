#!/bin/bash

legacy() {

    bash -c "$(curl -fsSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/Legacy-Menu.sh)"

    exit 0

}

tui() {

    bash -c "$(curl -fsSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/TUI-Menu.sh)"

    exit 0

}

while true; do
    echo "
╭━━━╮╱╱╱╱╱╱╱╱╱╭━━╮╱╱╱╱╱╱╱╭━━━╮╱╱╱╱╱╭━╮╱╱╱╱╭━━╮╱╱╱╱╱╭╮╱╱╱╭╮╭╮
┃╭━╮┃╱╱╱╱╱╱╱╱╱┃╭╮┃╱╱╱╱╱╱╱┃╭━╮┃╱╱╱╱╱┃╭╯╱╱╱╱╰┫┣╯╱╱╱╱╭╯╰╮╱╱┃┃┃┃
┃╰━━┳┳━╮╭━━╮╱╱┃╰╯╰┳━━┳╮╭╮┃┃╱╰╋━━┳━┳╯╰┳┳━━╮╱┃┃╭━╮╭━┻╮╭╋━━┫┃┃┃╭━━┳━╮
╰━━╮┣┫╭╮┫╭╮┣━━┫╭━╮┃╭╮┣╋╋╯┃┃╱╭┫╭╮┃╭╋╮╭╋┫╭╮┃╱┃┃┃╭╮┫━━┫┃┃╭╮┃┃┃┃┃┃━┫╭╯
┃╰━╯┃┃┃┃┃╰╯┣━━┫╰━╯┃╰╯┣╋╋╮┃╰━╯┃╰╯┃┃┃┃┃┃┃╰╯┃╭┫┣┫┃┃┣━━┃╰┫╭╮┃╰┫╰┫┃━┫┃
╰━━━┻┻╯╰┻━╮┃╱╱╰━━━┻━━┻╯╰╯╰━━━┻━━┻╯╰┻╯╰┻━╮┃╰━━┻╯╰┻━━┻━┻╯╰┻━┻━┻━━┻╯
╱╱╱╱╱╱╱╱╭━╯┃╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭━╯┃
╱╱╱╱╱╱╱╱╰━━╯╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╰━━╯"

    echo "By theTCS"

    echo

    echo "
▒█▀▀▀█ █▀▀ █░░ █▀▀ █▀▀ ▀▀█▀▀ 　 █▀▄▀█ █▀▀ █▀▀▄ █░░█ 　 ▄ 
░▀▀▀▄▄ █▀▀ █░░ █▀▀ █░░ ░░█░░ 　 █░▀░█ █▀▀ █░░█ █░░█ 　 ░ 
▒█▄▄▄█ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ░░▀░░ 　 ▀░░░▀ ▀▀▀ ▀░░▀ ░▀▀▀ 　 ▀"

    echo

    echo

    echo

    # Color
    GREEN="\e[32m"
    RESET="\e[0m"

    # Call the functions to collect system information
    check_system_info
    check_system_ip

    # List of processes to check, along with their custom names
    processes=("SH:Hysteria2" "TS:TUIC" "sing-box:Reality" "ST:ShadowTLS" "SBW:WARP")

    # Display the collected system information
    echo "#######################################################"    
    echo "${GREEN}Operating System:${RESET} $SYS"
    echo "${GREEN}Kernel:${RESET} $KERNEL"
    echo "${GREEN}Architecture:${RESET} $ARCHITECTURE"
    echo "${GREEN}Virtualization:${RESET} $VIRT"
    echo "${GREEN}IPv4:${RESET} $WAN4 $COUNTRY4"
    echo "${GREEN}IPv6:${RESET} $WAN6 $COUNTRY6"
    echo "======================================================="
    for process_info in "${processes[@]}"; do
        IFS=":" read -r process_name custom_name <<<"$process_info"
        check_and_display_process_status "$process_name" "$custom_name"
    done
    echo "======================================================="
    echo "#######################################################" 
    echo
    echo -e "1:  \e[93mTUI Menu\e[0m"
    echo -e "2:  \e[93mLegacy Menu\e[0m"
    echo -e "0:  \e[95mExit\e[0m"

    read -p "Enter your choice: " user_choice

    case $user_choice in

    1)
        sudo apt update
        sudo apt install dialog qrencode jq openssl python3 python3-pip -y
        pip install httpx requests --break-system-packages

        clear
        tui
        ;;
    2)
        sudo apt update
        sudo apt install dialog qrencode jq openssl python3 python3-pip -y
        pip install httpx requests --break-system-packages

        clear
        legacy
        ;;
    0)
        clear
        echo "Exiting."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;

    esac
done
