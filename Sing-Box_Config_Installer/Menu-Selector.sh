#!/bin/bash

check_system_info() {
  # Determine virtualization
  if [ $(type -p systemd-detect-virt) ]; then
    VIRT=$(systemd-detect-virt)
  elif [ $(type -p hostnamectl) ]; then
    VIRT=$(hostnamectl | awk '/Virtualization/{print $NF}')
  elif [ $(type -p virt-what) ]; then
    VIRT=$(virt-what)
  fi

  [ -s /etc/os-release ] && SYS="$(grep -i pretty_name /etc/os-release | cut -d \" -f2)"
  [[ -z "$SYS" && $(type -p hostnamectl) ]] && SYS="$(hostnamectl | grep -i system | cut -d : -f2)"
  [[ -z "$SYS" && $(type -p lsb_release) ]] && SYS="$(lsb_release -sd)"
  [[ -z "$SYS" && -s /etc/lsb-release ]] && SYS="$(grep -i description /etc/lsb-release | cut -d \" -f2)"
  [[ -z "$SYS" && -s /etc/redhat-release ]] && SYS="$(grep . /etc/redhat-release)"
  [[ -z "$SYS" && -s /etc/issue ]] && SYS="$(grep . /etc/issue | cut -d '\' -f1 | sed '/^[ ]*$/d')"

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "amazon linux" "arch linux" "alpine")
  RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Arch" "Alpine")
  EXCLUDE=("")
  MAJOR=("9" "16" "7" "7" "" "")

  for int in "${!REGEX[@]}"; do [[ $(tr 'A-Z' 'a-z' <<<"$SYS") =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break; done
  [ -z "$SYSTEM" ] && error " $(text 5) "

  # First exclude specific systems included in EXCLUDE. Other systems need to be compared with major releases.
  for ex in "${EXCLUDE[@]}"; do [[ ! $(tr 'A-Z' 'a-z' <<<"$SYS") =~ $ex ]]; done &&
    [[ "$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)" -lt "${MAJOR[int]}" ]] && error " $(text_eval 6) "

  KERNEL=$(uname -r)
  ARCHITECTURE=$(uname -m)

  mem_info=$(grep MemTotal /proc/meminfo)
  total_memory=$(echo $mem_info | awk '{print $2}')
  mem_info=$(grep MemAvailable /proc/meminfo)
  used_memory=$(echo $mem_info | awk '{print $2}')
  ram_usage_percentage=$(awk "BEGIN {printf \"%.2f\", ($used_memory / $total_memory) * 100}")



  storage_info=$(df / | awk 'NR==2{print $3,$2}')
  used_storage=$(echo $storage_info | awk '{print $1}')
  total_storage=$(echo $storage_info | awk '{print $2}')
  storage_usage_percentage=$(awk "BEGIN {printf \"%.2f\", $used_storage / $total_storage * 100}")

  cpu_info=($(grep 'cpu ' /proc/stat))
  prev_idle="${cpu_info[4]}"
  prev_total=0

  for value in "${cpu_info[@]}"; do
    prev_total=$((prev_total + value))
  done

  sleep 1

  cpu_info=($(grep 'cpu ' /proc/stat))
  idle="${cpu_info[4]}"
  total=0

  for value in "${cpu_info[@]}"; do
    total=$((total + value))
  done

  delta_idle=$((idle - prev_idle))
  delta_total=$((total - prev_total))
  cpu_usage_percentage=$((100 * (delta_total - delta_idle) / delta_total))

}

# Check IPv4 IPv6 information
check_system_ip() {
  IP4=$(wget -4 -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 http://ip-api.com/json/) &&
    WAN4=$(curl -4 ip.sb) &&
    COUNTRY4=$(expr "$IP4" : '.*country\":[ ]*\"\([^"]*\).*') &&
    ISP4=$(expr "$IP4" : '.*isp\":[ ]*\"\([^"]*\).*') &&
    [[ "$L" = C && -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")

  IP6=$(wget -6 -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://api.ip.sb/geoip) &&
    WAN6=$(curl -6 ip.sb) &&
    [[ "$L" = C && -n "$COUNTRY6" ]] && COUNTRY6=$(translate "$COUNTRY6")

}

check_and_display_process_status() {
  PROCESS_NAME="$1"
  CUSTOM_NAME="$2"
  PID=$(pgrep -o -x "$PROCESS_NAME")
  if [ -n "$PID" ]; then
    echo -e "$CUSTOM_NAME: \e[32mOpen\e[0m (PID: $PID)"
  else
    echo -e "$CUSTOM_NAME: \e[31mClosed\e[0m"
  fi
}

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

  # Call the functions to collect system information
  check_system_info
  check_system_ip

  # List of processes to check, along with their custom names
  processes=("SH:Hysteria2" "TS:TUIC" "RS:Reality" "ST:ShadowTLS" "SBW:WARP")

  # Display the collected system information
  echo "#######################################################"
  echo "Operating System: $SYS"
  echo "Kernel: $KERNEL"
  echo "Architecture: $ARCHITECTURE"
  echo "Virtualization: $VIRT"
  echo "======================================================="
  echo "RAM Usage: $ram_usage_percentage%"
  echo "CPU Usage: $cpu_usage_percentage%"
  echo "Storage Usage: $storage_usage_percentage%"
  echo "======================================================="
  echo "IPv4: $WAN4"
  echo "IPv6: $WAN6"
  echo "Country/ISP: $COUNTRY4 $ISP4"
  echo "======================================================="
  for process_info in "${processes[@]}"; do
    IFS=":" read -r process_name custom_name <<<"$process_info"
    check_and_display_process_status "$process_name" "$custom_name"
  done
  echo "#######################################################"

  echo

  echo "
▒█▀▀▀█ █▀▀ █░░ █▀▀ █▀▀ ▀▀█▀▀ 　 █▀▄▀█ █▀▀ █▀▀▄ █░░█ 　 ▄ 
░▀▀▀▄▄ █▀▀ █░░ █▀▀ █░░ ░░█░░ 　 █░▀░█ █▀▀ █░░█ █░░█ 　 ░ 
▒█▄▄▄█ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ░░▀░░ 　 ▀░░░▀ ▀▀▀ ▀░░▀ ░▀▀▀ 　 ▀"

  echo

  echo

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
