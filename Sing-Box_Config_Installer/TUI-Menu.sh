#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/Source.sh)

while true; do
    user_choice=$(dialog --clear --title "Main Menu" --menu "Please select a protocol:" 16 60 5 \
        "Server Optimizer" "Optimize the server" \
        "Update Sing-Box Cores" "Update Sing-Box Cores" \
        "" "" \
        "Hysteria2" "Manage Hysteria2" \
        "Tuic" "Manage Tuic" \
        "Reality" "Manage Reality" \
        "ShadowTLS" "Manage ShadowTLS" \
        "Warp" "Manage Warp" \
        "Exit" "Exit the script" 3>&1 1>&2 2>&3)

    case $user_choice in
    "Server Optimizer")
        optimize_server
        ;;
    "Update Sing-Box Cores")
        update_sing-box_core
        ;;
    "Hysteria2")
        while true; do
            user_choice=$(dialog --clear --title "Hysteria2 Menu" --menu "Please select an option:" 25 80 15 \
                "Install Hysteria2" "Install Hysteria2" \
                "Modify Hysteria2 Config" "Modify Hysteria2 Config" \
                "Show Hysteria2 Config" "Show Hysteria2 Config" \
                "Enable/Disable WARP on Hysteria2" "Enable/Disable WARP on Hysteria2" \
                "Uninstall Hysteria2" "Uninstall Hysteria2" \
                "Back" "Back to Main Menu" 3>&1 1>&2 2>&3)

            case $user_choice in
            "Install Hysteria2")
                install_hysteria
                ;;
            "Modify Hysteria2 Config")
                modify_hysteria_config
                ;;
            "Show Hysteria2 Config")
                show_hysteria_config
                ;;
            "Enable/Disable WARP on Hysteria2")
                toggle_warp_hysteria
                ;;
            "Uninstall Hysteria2")
                uninstall_hysteria
                ;;
            "Back")
                break
                ;;
            *)
                dialog --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Tuic")
        while true; do
            user_choice=$(dialog --clear --title "Tuic Menu" --menu "Please select an option:" 25 80 15 \
                "Install Tuic" "Install Tuic" \
                "Modify Tuic Config" "Modify Tuic Config" \
                "Show Tuic Config" "Show Tuic Config" \
                "Enable/Disable WARP on Tuic" "Enable/Disable WARP on Tuic" \
                "Uninstall Tuic" "Uninstall Tuic" \
                "Back" "Back to Main Menu" 3>&1 1>&2 2>&3)

            case $user_choice in
            "Install Tuic")
                install_tuic
                ;;
            "Modify Tuic Config")
                modify_tuic_config
                ;;
            "Show Tuic Config")
                show_tuic_config
                ;;
            "Enable/Disable WARP on Tuic")
                toggle_warp_tuic
                ;;
            "Uninstall Tuic")
                uninstall_tuic
                ;;
            "Back")
                break
                ;;
            *)
                dialog --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Reality")
        while true; do
            user_choice=$(dialog --clear --title "Reality Menu" --menu "Please select an option:" 25 80 15 \
                "Install Reality" "Install Reality" \
                "Modify Reality Config" "Modify Reality Config" \
                "Show Reality Config" "Show Reality Config" \
                "Enable/Disable WARP on Reality" "Enable/Disable WARP on Reality" \
                "Uninstall Reality" "Uninstall Reality" \
                "Back" "Back to Main Menu" 3>&1 1>&2 2>&3)

            case $user_choice in
            "Install Reality")
                install_reality
                ;;
            "Modify Reality Config")
                modify_reality_config
                ;;
            "Show Reality Config")
                show_reality_config
                ;;
            "Enable/Disable WARP on Reality")
                toggle_warp_reality
                ;;
            "Uninstall Reality")
                uninstall_reality
                ;;
            "Back")
                break
                ;;
            *)
                dialog --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "ShadowTLS")
        while true; do
            user_choice=$(dialog --clear --title "ShadowTLS Menu" --menu "Please select an option:" 25 80 15 \
                "Install ShadowTLS" "Install ShadowTLS" \
                "Modify ShadowTLS Config" "Modify ShadowTLS Config" \
                "Show ShadowTLS Config" "Show ShadowTLS Config" \
                "Enable/Disable WARP on ShadowTLS" "Enable/Disable WARP on ShadowTLS" \
                "Uninstall ShadowTLS" "Uninstall ShadowTLS" \
                "Back" "Back to Main Menu" 3>&1 1>&2 2>&3)

            case $user_choice in
            "Install ShadowTLS")
                install_shadowtls
                ;;
            "Modify ShadowTLS Config")
                modify_shadowtls_config
                ;;
            "Show ShadowTLS Config")
                show_shadowtls_config
                ;;
            "Enable/Disable WARP on ShadowTLS")
                toggle_warp_shadowtls
                ;;
            "Uninstall ShadowTLS")
                uninstall_shadowtls
                ;;
            "Back")
                break
                ;;
            *)
                dialog --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Warp")
        while true; do
            user_choice=$(
                dialog --clear --title "Warp Menu" --menu "Please select an option:" 25 80 15 \
                    "Generate WARP+ Key" "Generate WARP+ Key" \
                    "Install Warp" "Install Warp" \
                    "Show Warp Config" "Show Warp Config" \
                    "Uninstall Warp" "Uninstall Warp" \
                    "Back" "Back to Main Menu" 3>&1 1>&2 2>&3
            )

            case $user_choice in
            "Generate WARP+ Key")
                warp_key_gen
                ;;
            "Install Warp")
                install_warp
                ;;
            "Show Warp Config")
                show_warp_config
                ;;
            "Uninstall Warp")
                uninstall_warp
                ;;
            "Back")
                break
                ;;
            *)
                dialog --msgbox "Invalid choice. Please select a valid option." 10 30
                ;;
            esac
        done
        ;;
    "Exit")
        echo "Exiting."
        clear
        exit 0
        ;;
    *)
        dialog --msgbox "Invalid choice. Please select a valid option." 10 30
        ;;
    esac
done
