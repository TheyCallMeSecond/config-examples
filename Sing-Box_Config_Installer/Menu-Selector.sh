#!/bin/bash

source <(curl -sSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/Source.sh)

if ! grep -qxF 'alias sci="bash <(curl -fsSL https://bit.ly/config-installer)"' ~/.bashrc; then
    echo 'alias sci="bash <(curl -fsSL https://bit.ly/config-installer)"' >> ~/.bashrc
    alias sci="bash <(curl -fsSL https://bit.ly/config-installer)"
    source ~/.bashrc
fi

source ~/.bashrc

get_cpu_usage
get_ram_usage
get_storage_usage
check_system_info
check_system_ip

processes=("SH:Hysteria2:/etc/hysteria2/server.json" "ST:ShadowTLS:/etc/shadowtls/config.json" "WS:WebSocket:/etc/ws/config.json" "RS:Reality:/etc/reality/config.json" "NS:Naive:/etc/naive/config.json" "TS:TUIC:/etc/tuic/server.json")

while true; do
  echo "
╭━━━╮╱╱╱╱╱╱╱╱╱╭━━╮╱╱╱╱╱╱╱╭━━━╮╱╱╱╱╱╭━╮╱╱╱╱╭━━╮╱╱╱╱╱╭╮╱╱╱╭╮╭╮
┃╭━╮┃╱╱╱╱╱╱╱╱╱┃╭╮┃╱╱╱╱╱╱╱┃╭━╮┃╱╱╱╱╱┃╭╯╱╱╱╱╰┫┣╯╱╱╱╱╭╯╰╮╱╱┃┃┃┃
┃╰━━┳┳━╮╭━━╮╱╱┃╰╯╰┳━━┳╮╭╮┃┃╱╰╋━━┳━┳╯╰┳┳━━╮╱┃┃╭━╮╭━┻╮╭╋━━┫┃┃┃╭━━┳━╮
╰━━╮┣┫╭╮┫╭╮┣━━┫╭━╮┃╭╮┣╋╋╯┃┃╱╭┫╭╮┃╭╋╮╭╋┫╭╮┃╱┃┃┃╭╮┫━━┫┃┃╭╮┃┃┃┃┃┃━┫╭╯
┃╰━╯┃┃┃┃┃╰╯┣━━┫╰━╯┃╰╯┣╋╋╮┃╰━╯┃╰╯┃┃┃┃┃┃┃╰╯┃╭┫┣┫┃┃┣━━┃╰┫╭╮┃╰┫╰┫┃━┫┃
╰━━━┻┻╯╰┻━╮┃╱╱╰━━━┻━━┻╯╰╯╰━━━┻━━┻╯╰┻╯╰┻━╮┃╰━━┻╯╰┻━━┻━┻╯╰┻━┻━┻━━┻╯
╱╱╱╱╱╱╱╱╭━╯┃╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╭━╯┃
╱╱╱╱╱╱╱╱╰━━╯╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╱╰━━╯V5.0.0"

  echo "By theTCS"

  echo

  echo "#######################################################"
  echo "Operating System: $SYS"
  echo "Kernel: $KERNEL"
  echo "Architecture: $ARCHITECTURE"
  echo "Virtualization: $VIRT"
  echo "======================================================="
  echo "CPU Usage: $cpu_usage%"
  echo "Memory Usage: $memory_usage%"
  echo "Storage Usage: $storage_usage%"
  echo "======================================================="
  echo "IPv4: $WAN4"
  echo "IPv6: $WAN6"
  echo "Country/ISP: $COUNTRY $ISP"
  echo "======================================================="
  for process_info in "${processes[@]}"; do
    IFS=":" read -r process_name custom_name json_file <<<"$process_info"
    check_and_display_process_status "$process_name" "$custom_name" "$json_file"
  done
  echo "#######################################################"

  echo

  echo "
▒█▀▀▀█ █▀▀ █░░ █▀▀ █▀▀ ▀▀█▀▀ 　 █▀▄▀█ █▀▀ █▀▀▄ █░░█ 　 ▄ 
░▀▀▀▄▄ █▀▀ █░░ █▀▀ █░░ ░░█░░ 　 █░▀░█ █▀▀ █░░█ █░░█ 　 ░ 
▒█▄▄▄█ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ░░▀░░ 　 ▀░░░▀ ▀▀▀ ▀░░▀ ░▀▀▀ 　 ▀"

  echo

  echo

  echo -e "00: \e[91mInstall Required Packages\e[0m
   (Select this for first use)"
  echo ------------------------------
  echo -e "1:  \e[93mTUI Menu\e[0m"
  echo -e "2:  \e[93mLegacy Menu\e[0m"
  echo -e "0:  \e[95mExit\e[0m"

  read -p "Enter your choice: " user_choice

  case $user_choice in

  00)
    clear
    install_required_packages
    ;;
  1)
    clear
    tui
    ;;
  2)
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
