#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/Source.sh)

while true; do
    user_choice=$(whiptail --clear --title "Main Menu" --menu "Please select a protocol:" 25 50 15 \
        "Optimize" "     Optimize Server" \
        "Update" "     Update Sing-Box Cores" \
        "" "" \
        "Hysteria2" "     Manage Hysteria2" \
        "Tuic" "     Manage Tuic" \
        "Reality" "     Manage Reality" \
        "ShadowTLS" "     Manage ShadowTLS" \
        "WebSocket" "     Manage WebSocket" \
        "Warp" "     Manage Warp" \
        "Exit" "     Exit the script" 3>&1 1>&2 2>&3)

    case $user_choice in
    "Optimize")
        clear
        optimize_server
        ;;
    "Update")
        clear
        update_sing-box_core
        ;;
    "Hysteria2")
        while true; do
            user_choice=$(
                whiptail --clear --title "Hysteria2 Menu" --menu "Please select an option:" 25 50 15 \
                    "1" "Install Hysteria2" \
                    "2" "Modify Hysteria2 Config" \
                    "3" "Add a new user" \
                    "4" "Remove an existing user" \
                    "5" "Show User Configs" \
                    "6" "Enable/Disable WARP" \
                    "7" "Uninstall Hysteria2" \
                    "0" "Back to Main Menu" 3>&1 1>&2 2>&3
            )

            case $user_choice in
            "1")
                clear
                install_hysteria
                ;;
            "2")
                clear
                modify_hysteria_config
                ;;
            "3")
                clear
                add_hysteria_user
                ;;
            "4")
                clear
                remove_hysteria_user
                ;;
            "5")
                clear
                show_hysteria_config
                ;;
            "6")
                clear
                toggle_warp_hysteria
                ;;
            "7")
                clear
                uninstall_hysteria
                ;;

            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Tuic")
        while true; do
            user_choice=$(whiptail --clear --title "Tuic Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install Tuic" \
                "2" "Modify Tuic Config" \
                "3" "Add a new user" \
                "4" "Remove an existing user" \
                "5" "Show User Configs" \
                "6" "Enable/Disable WARP" \
                "7" "Uninstall Tuic" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

            case $user_choice in
            "1")
                clear
                install_tuic
                ;;
            "2")
                clear
                modify_tuic_config
                ;;
            "3")
                clear
                add_tuic_user
                ;;
            "4")
                clear
                remove_tuic_user
                ;;
            "5")
                clear
                show_tuic_config
                ;;
            "6")
                clear
                toggle_warp_tuic
                ;;
            "7")
                clear
                uninstall_tuic
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Reality")
        while true; do
            user_choice=$(whiptail --clear --title "Reality Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install Reality" \
                "2" "Modify Reality Config" \
                "3" "Regenerate Reality Keys" \
                "4" "Add a new user" \
                "5" "Remove an existing user" \
                "6" "Show User Configs" \
                "7" "Enable/Disable WARP" \
                "8" "Uninstall Reality" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

            case $user_choice in
            "1")
                clear
                install_reality
                ;;
            "2")
                clear
                modify_reality_config
                ;;
            "3")
                clear
                regenerate_keys
                ;;
            "4")
                clear
                add_reality_user
                ;;
            "5")
                clear
                remove_reality_user
                ;;
            "6")
                clear
                show_reality_config
                ;;
            "7")
                clear
                toggle_warp_reality
                ;;
            "8")
                clear
                uninstall_reality
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "ShadowTLS")
        while true; do
            user_choice=$(whiptail --clear --title "ShadowTLS Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install ShadowTLS" \
                "2" "Modify ShadowTLS Config" \
                "3" "Add a new user" \
                "4" "Remove an existing user" \
                "5" "Show User Configs" \
                "6" "Enable/Disable WARP" \
                "7" "Uninstall ShadowTLS" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

            case $user_choice in
            "1")
                clear
                install_shadowtls
                ;;
            "2")
                clear
                modify_shadowtls_config
                ;;
            "3")
                clear
                add_shadowtls_user
                ;;
            "4")
                clear
                remove_shadowtls_user
                ;;
            "5")
                clear
                show_shadowtls_config
                ;;
            "6")
                clear
                toggle_warp_shadowtls
                ;;
            "7")
                clear
                uninstall_shadowtls
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "WebSocket")
        while true; do
            user_choice=$(whiptail --clear --title "WebSocket Menu" --menu "Please select an option:" 25 50 15 \
                "1" "Install WebSocket" \
                "2" "Modify WebSocket Config" \
                "3" "Add a new user" \
                "4" "Remove an existing user" \
                "5" "Show User Configs" \
                "6" "Enable/Disable WARP" \
                "7" "Uninstall WebSocket" \
                "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

            case $user_choice in
            "1")
                clear
                install_ws
                ;;
            "2")
                clear
                modify_ws_config
                ;;
            "3")
                clear
                add_ws_user
                ;;
            "4")
                clear
                remove_ws_user
                ;;
            "5")
                clear
                show_ws_config
                ;;
            "6")
                clear
                toggle_warp_ws
                ;;
            "7")
                clear
                uninstall_ws
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Warp")
        while true; do
            user_choice=$(
                whiptail --clear --title "Warp Menu" --menu "Please select an option:" 25 50 15 \
                    "1" "Generate WARP+ Key" \
                    "2" "Generate WARP+ Wireguard Config" \
                    "3" "Show Warp Config" \
                    "4" "Uninstall Warp" \
                    "0" "Back to Main Menu" 3>&1 1>&2 2>&3
            )

            case $user_choice in
            "1")
                clear
                warp_key_gen
                ;;
            "2")
                clear
                install_warp
                ;;
            "3")
                clear
                show_warp_config
                ;;
            "4")
                clear
                uninstall_warp
                ;;
            "0")
                break
                ;;
            *)
                whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Exit")
        clear
        echo "Exiting."
        exit 0
        ;;
    *)
        whiptail --msgbox "Invalid choice. Please select a valid option." 10 30
        ;;
    esac
done
