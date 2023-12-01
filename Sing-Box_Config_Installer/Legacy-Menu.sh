#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/Source.sh)

while true; do
    echo "Main Menu:"
    echo -e
    echo -e "000)\e[95mOptimize Server\e[0m"
    echo -e    
    echo -e "00) \e[95mUpdate Sing-Box Core\e[0m"
    echo -e    
    echo -e "#########################"
    echo -e
    echo -e "1)  VLESS-WebSocket-tls"
    echo -e
    echo -e "2)  VLESS-gRPC-tls"
    echo -e
    echo -e "3)  ShadowTLS"
    echo -e
    echo -e "4)  Hysteria2"
    echo -e
    echo -e "5)  Reality"
    echo -e
    echo -e "6)  TUIC-V5"
    echo -e
    echo -e "7)  Naive"
    echo -e
    echo -e "8)  WARP"
    echo -e
    echo -e "#########################"
    echo -e
    echo -e "0)  \e[95mExit\e[0m"
    echo -e

    read -p "Enter choice: " choice

    case $choice in
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
        while true; do
            echo "VLESS-WebSocket-tls:"
            echo -e "1) Install"
            echo -e "2) Modify Config"
            echo -e "3) Add User"
            echo -e "4) Remove User"
            echo -e "5) Show User Configs"
            echo -e "6) Enable/Disable WARP"
            echo -e "7) Uninstall"
            echo -e "0) \e[95mBack\e[0m"

            read -p "Enter choice: " subchoice

            case $subchoice in
            1)
                clear
                install_ws
                ;;
            2)
                clear
                modify_ws_config
                ;;
            3)
                clear
                add_ws_user
                ;;
            4)
                clear
                remove_ws_user
                ;;
            5)
                clear
                show_ws_config
                ;;
            6)
                clear
                toggle_warp_ws
                ;;
            7)
                clear
                uninstall_grpc
                ;;
            0)
                clear
                break
                ;;
            *)
                clear
                ;;
            esac
        done
        ;;
    2)
        clear
        while true; do
            echo "VLESS-gRPC-tls:"
            echo -e "1) Install"
            echo -e "2) Modify Config"
            echo -e "3) Add User"
            echo -e "4) Remove User"
            echo -e "5) Show User Configs"
            echo -e "6) Enable/Disable WARP"
            echo -e "7) Uninstall"
            echo -e "0) \e[95mBack\e[0m"

            read -p "Enter choice: " subchoice

            case $subchoice in
            1)
                clear
                install_grpc
                ;;
            2)
                clear
                modify_grpc_config
                ;;
            3)
                clear
                add_grpc_user
                ;;
            4)
                clear
                remove_grpc_user
                ;;
            5)
                clear
                show_grpc_config
                ;;
            6)
                clear
                toggle_warp_grpc
                ;;
            7)
                clear
                uninstall_grpc
                ;;
            0)
                clear
                break
                ;;
            *)
                clear
                ;;
            esac
        done
        ;;
    3)
        clear
        while true; do
            echo "ShadowTLS:"
            echo -e "1) Install"
            echo -e "2) Modify Config"
            echo -e "3) Add User"
            echo -e "4) Remove User"
            echo -e "5) Show User Configs"
            echo -e "6) Enable/Disable WARP"
            echo -e "7) Uninstall"
            echo -e "0) \e[95mBack\e[0m"

            read -p "Enter choice: " subchoice

            case $subchoice in
            1)
                clear
                install_shadowtls
                ;;
            2)
                clear
                modify_shadowtls_config
                ;;
            3)
                clear
                add_shadowtls_user
                ;;
            4)
                clear
                remove_shadowtls_user
                ;;
            5)
                clear
                show_shadowtls_config
                ;;
            6)
                clear
                toggle_warp_shadowtls
                ;;
            7)
                clear
                uninstall_shadowtls
                ;;
            0)
                clear
                break
                ;;
            *)
                clear
                ;;
            esac
        done
        ;;
    4)
        clear
        while true; do
            echo "Hysteria2:"
            echo -e "1) Install"
            echo -e "2) Modify Config"
            echo -e "3) Add User"
            echo -e "4) Remove User"
            echo -e "5) Show User Configs"
            echo -e "6) Enable/Disable WARP"
            echo -e "7) Uninstall"
            echo -e "0) \e[95mBack\e[0m"

            read -p "Enter choice: " subchoice

            case $subchoice in
            1)
                clear
                hysteria_check="/etc/hysteria2/server.json"

                if [ -e "$hysteria_check" ]; then
                    whiptail --msgbox "Hysteria2 is Already installed " 10 30
                    clear
                else
                    while true; do
                        echo "Please select an option:"
                        echo -e "1) With OBFS"
                        echo -e "2) Without OBFS"
                        read -p "Enter your choice: " sub_choice2

                        case $sub_choice2 in
                        1)
                            clear
                            install_hysteria obfs
                            ;;
                        2)
                            clear
                            install_hysteria native
                            ;;
                        *)
                            clear
                            ;;
                        esac
                        break
                    done
                fi
                ;;
            2)
                clear
                hysteria_check="/etc/hysteria2/server.json"

                if [ -e "$hysteria_check" ]; then
                    while true; do
                        echo "Please select an option:"
                        echo -e "1) With OBFS"
                        echo -e "2) Without OBFS"
                        read -p "Enter your choice: " sub_choice2

                        case $sub_choice2 in
                        1)
                            clear
                            modify_hysteria_config obfs
                            ;;
                        2)
                            clear
                            modify_hysteria_config native
                            ;;
                        *)
                            clear
                            ;;
                        esac
                        break
                    done
                else
                    whiptail --msgbox "Hysteria2 is not installed yet." 10 30
                    clear
                fi
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
            0)
                clear
                break
                ;;
            *)
                clear
                ;;
            esac
        done
        ;;
    5)
        clear
        while true; do
            echo "Reality:"
            echo -e "1) Install"
            echo -e "2) Modify Config"
            echo -e "3) Regenerate Keys"
            echo -e "4) Add User"
            echo -e "5) Remove User"
            echo -e "6) Show User Configs"
            echo -e "7) Enable/Disable WARP"
            echo -e "8) Uninstall"
            echo -e "0) \e[95mBack\e[0m"

            read -p "Enter choice: " subchoice

            case $subchoice in
            1)
                clear
                reality_check="/etc/reality/config.json"

                if [ -e "$reality_check" ]; then
                    whiptail --msgbox "Reality is Already installed " 10 30
                    clear
                else
                    while true; do
                        echo "Please select Transport Type:"
                        echo -e "1) gRPC"
                        echo -e "2) TCP"
                        read -p "Enter your choice: " sub_choice2

                        case $sub_choice2 in
                        1)
                            clear
                            install_reality grpc
                            ;;
                        2)
                            clear
                            install_reality tcp
                            ;;
                        *)
                            clear
                            ;;
                        esac
                        break
                    done
                fi
                ;;
            2)
                clear
                reality_check="/etc/reality/config.json"

                if [ -e "$reality_check" ]; then
                    while true; do
                        echo "Please select Transport Type:"
                        echo -e "1) gRPC"
                        echo -e "2) TCP"
                        read -p "Enter your choice: " sub_choice2

                        case $sub_choice2 in
                        1)
                            clear
                            modify_reality_config grpc
                            ;;
                        2)
                            clear
                            modify_reality_config tcp
                            ;;
                        *)
                            clear
                            ;;
                        esac
                        break
                    done
                else
                    whiptail --msgbox "Reality is not installed yet." 10 30
                    clear
                fi
                ;;
            3)
                clear
                regenerate_keys
                ;;
            4)
                clear
                add_reality_user
                ;;
            5)
                clear
                remove_reality_user
                ;;
            6)
                clear
                show_reality_config
                ;;
            7)
                clear
                toggle_warp_reality
                ;;
            8)
                clear
                uninstall_reality
                ;;
            0)
                clear
                break
                ;;
            *)
                clear
                ;;
            esac
        done
        ;;
    6)
        clear
        while true; do
            echo "TUIC-V5:"
            echo -e "1) Install"
            echo -e "2) Modify Config"
            echo -e "3) Add User"
            echo -e "4) Remove User"
            echo -e "5) Show User Configs"
            echo -e "6) Enable/Disable WARP"
            echo -e "7) Uninstall"
            echo -e "0) \e[95mBack\e[0m"

            read -p "Enter choice: " subchoice

            case $subchoice in
            1)
                clear
                install_tuic
                ;;
            2)
                clear
                modify_tuic_config
                ;;
            3)
                clear
                add_tuic_user
                ;;
            4)
                clear
                remove_tuic_user
                ;;
            5)
                clear
                show_tuic_config
                ;;
            6)
                clear
                toggle_warp_tuic
                ;;
            7)
                clear
                uninstall_tuic
                ;;
            0)
                clear
                break
                ;;
            *)
                clear
                ;;
            esac
        done
        ;;
    7)
        clear
        while true; do
            echo "Naive:"
            echo -e "1) Install"
            echo -e "2) Modify Config"
            echo -e "3) Add User"
            echo -e "4) Remove User"
            echo -e "5) Show User Configs"
            echo -e "6) Enable/Disable WARP"
            echo -e "7) Uninstall"
            echo -e "0) \e[95mBack\e[0m"

            read -p "Enter choice: " subchoice

            case $subchoice in
            1)
                clear
                install_naive
                ;;
            2)
                clear
                modify_naive_config
                ;;
            3)
                clear
                add_naive_user
                ;;
            4)
                clear
                remove_naive_user
                ;;
            5)
                clear
                show_naive_config
                ;;
            6)
                clear
                toggle_warp_naive
                ;;
            7)
                clear
                uninstall_naive
                ;;
            0)
                clear
                break
                ;;
            *)
                clear
                ;;
            esac
        done
        ;;
    8)
        clear
        while true; do
            echo "WARP:"
            echo -e "1) Generate WARP+ Key"
            echo -e "2) Generate WARP+ Wireguard Config"
            echo -e "3) Show Config"
            echo -e "4) Uninstall"
            echo -e "0) \e[95mBack\e[0m"

            read -p "Enter choice: " subchoice

            case $subchoice in
            1)
                clear
                warp_key_gen
                ;;
            2)
                clear
                install_warp
                ;;
            3)
                clear
                show_warp_config
                ;;
            4)
                clear
                uninstall_warp
                ;;
            0)
                clear
                break
                ;;
            *)
                clear
                ;;
            esac
        done
        ;;
    0)
        exit 0
        ;;
    *)
        clear
        ;;
    esac
done
