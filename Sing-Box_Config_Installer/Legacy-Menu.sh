#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/Source.sh)

# Main menu loop
while true; do
    echo -e "\e[91mPlease select an option:\e[0m"
    echo -e
    echo -e "000:\e[95mOptimize Server\e[0m"
    echo -e "00: \e[95mUpdate Sing-Box Core\e[0m"
    echo -------------------------------------------
    echo -e "1:  \e[93mInstall Hysteria2\e[0m"
    echo -e "2:  \e[93mModify Hysteria2 Config\e[0m"
    echo -e "3:  \e[93mAdd User\e[0m"
    echo -e "4:  \e[93mRemove User\e[0m"
    echo -e "5:  \e[93mShow Users Configs\e[0m"
    echo -e "6:  \e[93mEnable/Disable WARP on Hysteria2\e[0m"
    echo -e "7:  \e[93mUninstall Hysteria2\e[0m"
    echo -------------------------------------------
    echo -e "8:  \e[93mInstall TUIC\e[0m"
    echo -e "9:  \e[93mModify TUIC Config\e[0m"
    echo -e "10: \e[93mAdd User\e[0m"
    echo -e "11: \e[93mRemove User\e[0m"    
    echo -e "12: \e[93mShow Users Configs\e[0m"
    echo -e "13: \e[93mEnable/Disable WARP on TUIC\e[0m"
    echo -e "14: \e[93mUninstall TUIC\e[0m"
    echo -------------------------------------------
    echo -e "15: \e[93mInstall Reality\e[0m"
    echo -e "16: \e[93mModify Reality Config\e[0m"
    echo -e "17: \e[93mAdd User\e[0m"
    echo -e "18: \e[93mRemove User\e[0m"    
    echo -e "19: \e[93mShow Users Configs\e[0m"
    echo -e "20: \e[93mEnable/Disable WARP on Reality\e[0m"
    echo -e "21: \e[93mUninstall Reality\e[0m"
    echo -------------------------------------------
    echo -e "22: \e[93mInstall ShadowTLS\e[0m"
    echo -e "23: \e[93mModify ShadowTLS Config\e[0m"
    echo -e "24: \e[93mAdd User\e[0m"
    echo -e "25: \e[93mRemove User\e[0m"    
    echo -e "26: \e[93mShow Users Configs\e[0m"
    echo -e "27: \e[93mEnable/Disable WARP on ShadowTLS\e[0m"
    echo -e "28: \e[93mUninstall ShadowTLS\e[0m"
    echo -------------------------------------------
    echo -e "29: \e[93mGenerate WARP+ Key\e[0m"
    echo -e "30: \e[93mInstall WARP\e[0m"
    echo -e "31: \e[93mShow WARP Config\e[0m"
    echo -e "32: \e[93mUninstall WARP\e[0m"
    echo -------------------------------------------
    echo -e "0:  \e[95mExit\e[0m"

    read -p "Enter your choice: " user_choice

    case $user_choice in
    000)
        clear
        optimize_server
        ;;
    00)
        clear
        update_sing-box_core
        ;;
    1)
        clear
        install_hysteria
        ;;
    2)
        clear
        modify_hysteria_config
        ;;
    3)
        clear
        add_hysteria_user
        ;;
    4)
        clear
        remove_hysteria_user
        ;;                
    5)
        clear
        show_hysteria_config
        ;;
    6)
        clear
        toggle_warp_hysteria
        ;;
    7)
        clear
        uninstall_hysteria
        ;;
    8)
        clear
        install_tuic
        ;;
    9)
        clear
        modify_tuic_config
        ;;
    10)
        clear
        add_tuic_user
        ;;
    11)
        clear
        remove_tuic_user
        ;;                
    12)
        clear
        show_tuic_config
        ;;
    13)
        clear
        toggle_warp_tuic
        ;;
    14)
        clear
        uninstall_tuic
        ;;
    15)
        clear
        install_reality
        ;;
    16)
        clear
        modify_reality_config
        ;;
    17)
        clear
        add_reality_user
        ;;
    18)
        clear
        remove_reality_user
        ;;                
    19)
        clear
        show_reality_config
        ;;
    20)
        clear
        toggle_warp_reality
        ;;
    21)
        clear
        uninstall_reality
        ;;
    22)
        clear
        install_shadowtls
        ;;
    23)
        clear
        modify_shadowtls_config
        ;;
    24)
        clear
        add_shadowtls_user
        ;;
    25)
        clear
        remove_shadowtls_user
        ;;         
    26)
        clear
        show_shadowtls_config
        ;;
    27)
        clear
        toggle_warp_shadowtls
        ;;
    28)
        clear
        uninstall_shadowtls
        ;;
    29)
        clear
        warp_key_gen
        ;;
    30)
        clear
        install_warp
        ;;
    31)
        clear
        show_warp_config
        ;;
    32)
        clear
        uninstall_warp
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
