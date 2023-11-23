#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/Source.sh)

# Main menu loop
while true; do
    echo -e "\e[91mPlease select an option:\e[0m"
    echo -e
    echo -e "000:\e[95mOptimize Server\e[0m"
    echo -e "00: \e[95mUpdate Sing-Box Core\e[0m"
    echo ------------Hysteria2---------------
    echo -e "1:  \e[93mInstall\e[0m"
    echo -e "2:  \e[93mModify Config\e[0m"
    echo -e "3:  \e[93mAdd User\e[0m"
    echo -e "4:  \e[93mRemove User\e[0m"
    echo -e "5:  \e[93mShow User Configs\e[0m"
    echo -e "6:  \e[93mEnable/Disable WARP\e[0m"
    echo -e "7:  \e[93mUninstall\e[0m"
    echo --------------TUIC------------------
    echo -e "8:  \e[93mInstall\e[0m"
    echo -e "9:  \e[93mModify Config\e[0m"
    echo -e "10: \e[93mAdd User\e[0m"
    echo -e "11: \e[93mRemove User\e[0m"    
    echo -e "12: \e[93mShow User Configs\e[0m"
    echo -e "13: \e[93mEnable/Disable WARP\e[0m"
    echo -e "14: \e[93mUninstall\e[0m"
    echo -------------Reality----------------
    echo -e "15: \e[93mInstall\e[0m"
    echo -e "16: \e[93mModify Config\e[0m"
    echo -e "17: \e[93mRegenerate Keys\e[0m"
    echo -e "18: \e[93mAdd User\e[0m"
    echo -e "19: \e[93mRemove User\e[0m"    
    echo -e "20: \e[93mShow User Configs\e[0m"
    echo -e "21: \e[93mEnable/Disable WARP\e[0m"
    echo -e "22: \e[93mUninstall\e[0m"
    echo ------------ShadowTLS---------------
    echo -e "23: \e[93mInstall\e[0m"
    echo -e "24: \e[93mModify Config\e[0m"
    echo -e "25: \e[93mAdd User\e[0m"
    echo -e "26: \e[93mRemove User\e[0m"    
    echo -e "27: \e[93mShow User Configs\e[0m"
    echo -e "28: \e[93mEnable/Disable WARP\e[0m"
    echo -e "29: \e[93mUninstall\e[0m"
    echo ------------WebSocket---------------
    echo -e "30: \e[93mInstall\e[0m"
    echo -e "31: \e[93mModify Config\e[0m"
    echo -e "32: \e[93mAdd User\e[0m"
    echo -e "33: \e[93mRemove User\e[0m"    
    echo -e "34: \e[93mShow User Configs\e[0m"
    echo -e "35: \e[93mEnable/Disable WARP\e[0m"
    echo -e "36: \e[93mUninstall\e[0m"
    echo --------------WARP------------------    
    echo -e "37: \e[93mGenerate WARP+ Key\e[0m"
    echo -e "38: \e[93mGenerate WARP+ Wireguard Config\e[0m"
    echo -e "39: \e[93mShow Config\e[0m"
    echo -e "40: \e[93mUninstall\e[0m"
    echo ------------------------------------
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
        regenerate_keys
        ;;        
    18)
        clear
        add_reality_user
        ;;
    19)
        clear
        remove_reality_user
        ;;                
    20)
        clear
        show_reality_config
        ;;
    21)
        clear
        toggle_warp_reality
        ;;
    22)
        clear
        uninstall_reality
        ;;
    23)
        clear
        install_shadowtls
        ;;
    24)
        clear
        modify_shadowtls_config
        ;;
    25)
        clear
        add_shadowtls_user
        ;;
    26)
        clear
        remove_shadowtls_user
        ;;         
    27)
        clear
        show_shadowtls_config
        ;;
    28)
        clear
        toggle_warp_shadowtls
        ;;
    29)
        clear
        uninstall_shadowtls
        ;;
    30)
        clear
        install_ws
        ;;
    31)
        clear
        modify_ws_config
        ;;
    32)
        clear
        add_ws_user
        ;;
    33)
        clear
        remove_ws_user
        ;;         
    34)
        clear
        show_ws_config
        ;;
    35)
        clear
        toggle_warp_ws
        ;;
    36)
        clear
        uninstall_ws
        ;;        
    37)
        clear
        warp_key_gen
        ;;
    38)
        clear
        install_warp
        ;;
    39)
        clear
        show_warp_config
        ;;
    40)
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
