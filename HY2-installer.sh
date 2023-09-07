#!/bin/bash

# Main menu loop
while true; do
    echo -e "Please select an option:"
    echo -e "1: \e[93mInstall\e[0m"
    echo -e "2: \e[93mModify Config\e[0m"
    echo -e "3: \e[93mUninstall\e[0m"
    echo -e "4: \e[93mExit\e[0m"

    read -p "Enter your choice: " user_choice

    case $user_choice in
        1)
            install_hysteria
            ;;
        2)
            modify_config
            ;;
        3)
            uninstall_hysteria
            ;;
        4)
            echo "Exiting."
            exit 0  # Exit the script immediately
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
done

# Function to install Hysteria
install_hysteria() {

    curl -Lo /root/hysteria2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && chmod +x /root/hysteria2 && mv -f /root/hysteria2 /usr/bin


    mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server-auto.yaml


    curl -Lo /etc/systemd/system/hysteria2.service raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/hysteria2.service && systemctl daemon-reload


    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/hysteria2/server.yaml


    read -p "Please enter your domain: " user_domain
    sed -i "s/DOMAIN/$user_domain/" /etc/hysteria2/server.yaml


    read -s -p "Please enter your password: " user_password
    echo
    sed -i "s/PASSWORD/$user_password/" /etc/hysteria2/server.yaml


    read -p "Please enter your email: " user_email
    sed -i "s/EMAIL/$user_email/" /etc/hysteria2/server.yaml


    sudo systemctl enable hysteria2
    sudo systemctl start hysteria2


    result_url="hy2://$user_password@$user_domain:$user_port?insecure=1&sni=$user_domain#HY2"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL


    echo "Hysteria setup completed."
    exit 0  # Exit the script immediately
}

# Function to modify config
modify_config() {

    sudo systemctl stop hysteria2


    rm -rf /etc/hysteria2


    mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server-auto.yaml


    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/hysteria2/server.yaml


    read -p "Please enter your domain: " user_domain
    sed -i "s/DOMAIN/$user_domain/" /etc/hysteria2/server.yaml


    read -s -p "Please enter your password: " user_password
    echo
    sed -i "s/PASSWORD/$user_password/" /etc/hysteria2/server.yaml


    read -p "Please enter your email: " user_email
    sed -i "s/EMAIL/$user_email/" /etc/hysteria2/server.yaml


    sudo systemctl enable hysteria2
    sudo systemctl start hysteria2


    result_url="hy2://$user_password@$user_domain:$user_port?insecure=1&sni=$user_domain#HY2"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL


    echo "Hysteria setup completed."
    exit 0  # Exit the script immediately
}

# Function to uninstall Hysteria
uninstall_hysteria() {

    sudo systemctl stop hysteria2


    sudo rm -f /usr/bin/hysteria2
    rm -rf /etc/hysteria2
    sudo rm -f /etc/systemd/system/hysteria2.service

    echo "Hysteria uninstalled."
    
    exit 0  # Exit the script immediately with a successful status
}

