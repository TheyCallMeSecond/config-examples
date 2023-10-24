#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/Source.sh)

# Main menu loop
while true; do
    echo -e "    \e[91mPlease select an option:\e[0m"
    echo -e
    echo -e "000:\e[95mOptimize Server\e[0m"
    echo -e "00: \e[95mUpdate Sing-Box Core\e[0m"
    echo -------------------------------------------
    echo -e "1:  \e[93mInstall Hysteria2\e[0m"
    echo -e "2:  \e[93mModify Hysteria2 Config\e[0m"
    echo -e "3:  \e[93mShow Hysteria2 Config\e[0m"
    echo -e "4:  \e[93mEnable/Disable WARP on Hysteria2\e[0m"
    echo -e "5:  \e[93mUninstall Hysteria2\e[0m"
    echo -------------------------------------------
    echo -e "6:  \e[93mInstall TUIC\e[0m"
    echo -e "7:  \e[93mModify TUIC Config\e[0m"
    echo -e "8:  \e[93mShow TUIC Config\e[0m"
    echo -e "9:  \e[93mEnable/Disable WARP on TUIC\e[0m"
    echo -e "10: \e[93mUninstall TUIC\e[0m"
    echo -------------------------------------------
    echo -e "11: \e[93mInstall Reality\e[0m"
    echo -e "12: \e[93mModify Reality Config\e[0m"
    echo -e "13: \e[93mShow Reality Config\e[0m"
    echo -e "14: \e[93mEnable/Disable WARP on Reality\e[0m"
    echo -e "15: \e[93mUninstall Reality\e[0m"
    echo -------------------------------------------
    echo -e "16: \e[93mInstall ShadowTLS\e[0m"
    echo -e "17: \e[93mModify ShadowTLS Config\e[0m"
    echo -e "18: \e[93mShow ShadowTLS Config\e[0m"
    echo -e "19: \e[93mEnable/Disable WARP on ShadowTLS\e[0m"
    echo -e "20: \e[93mUninstall ShadowTLS\e[0m"
    echo -------------------------------------------
    echo -e "21: \e[93mGenerate WARP+ Key\e[0m"
    echo -e "22: \e[93mInstall WARP\e[0m"
    echo -e "23: \e[93mShow WARP Config\e[0m"
    echo -e "24: \e[93mUninstall WARP\e[0m"
    echo -------------------------------------------
    echo -e "0:  \e[95mExit\e[0m"

    read -p "Enter your choice: " user_choice

    case $user_choice in
    000)
        optimize_server
        ;;
    00)
        update_sing-box_core
        ;;
    1)
        install_hysteria
        ;;
    2)
        modify_hysteria_config
        ;;
    3)
        show_hysteria_config
        ;;
    4)
        toggle_warp_hysteria
        ;;
    5)
        uninstall_hysteria
        ;;
    6)
        install_tuic
        ;;
    7)
        modify_tuic_config
        ;;
    8)
        show_tuic_config
        ;;
    9)
        toggle_warp_tuic
        ;;
    10)
        uninstall_tuic
        ;;
    11)
        install_reality
        ;;
    12)
        modify_reality_config
        ;;
    13)
        show_reality_config
        ;;
    14)
        toggle_warp_reality
        ;;
    15)
        uninstall_reality
        ;;
    16)
        install_shadowtls
        ;;
    17)
        modify_shadowtls_config
        ;;
    18)
        show_shadowtls_config
        ;;
    19)
        toggle_warp_shadowtls
        ;;
    20)
        uninstall_shadowtls
        ;;
    21)
        warp_key_gen
        ;;
    22)
        install_warp
        ;;
    23)
        show_warp_config
        ;;
    24)
        uninstall_warp
        ;;
    0) 
        echo "Exiting."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
    esac

done
