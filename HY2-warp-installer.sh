#!/bin/bash

# Function to install Hysteria
install_hysteria() {
    # Step 1: Download Hysteria binary and make it executable
    curl -Lo /root/hysteria2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && chmod +x /root/hysteria2 && mv -f /root/hysteria2 /usr/bin

    # Step 2: Create a directory for Hysteria configuration and download the server.yaml file
    mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server-auto-warp.yaml

    # Step 3: download the hysteria2.service file
    curl -Lo /etc/systemd/system/hysteria2.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/hysteria2.service && systemctl daemon-reload

    # Step 4: Prompt the user to enter a port and replace "PORT" in the server.yaml file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/hysteria2/server.yaml

    # Step 5: Prompt the user to enter a domain and replace "DOMAIN" in the server.yaml file
    read -p "Please enter your domain: " user_domain
    sed -i "s/DOMAIN/$user_domain/" /etc/hysteria2/server.yaml

    # Step 6: Prompt the user to enter a password and replace "PASSWORD" in the server.yaml file
    read -s -p "Please enter your password: " user_password
    echo
    sed -i "s/PASSWORD/$user_password/" /etc/hysteria2/server.yaml

    # Step 7: Prompt the user to enter an email and replace "EMAIL" in the server.yaml file
    read -p "Please enter your email: " user_email
    sed -i "s/EMAIL/$user_email/" /etc/hysteria2/server.yaml
    
    # Step 8:Execute the WARP setup script (with user key replacement)
    bash <(curl -fsSL git.io/warp.sh) proxy

    # Step 9:Prompt the user for their WARP+ key
    read -p "Enter your WARP+ key: " warp_key

    # Step 10:Replace the placeholder in the command and run it
    warp_command="warp-cli set-license $warp_key"
    eval "$warp_command"

    # Step 11:Restart WARP
    bash <(curl -fsSL git.io/warp.sh) restart

    # Step 12: Enable and start the Hysteria2 service
    sudo systemctl enable hysteria2
    sudo systemctl start hysteria2
    
    # Step 13: Use a public DNS service to determine the public IP address
    public_ip=$(curl -s https://ipinfo.io/ip)

    # Step 14:Construct and display the resulting URL
    result_url="hy2://$user_password@$public_ip:$user_port?insecure=1&sni=$user_domain#HY2"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL

    echo "Hysteria setup completed."
    
    exit 0  # Exit the script immediately with a successful status
}

# Function to modify Hysteria configuration
modify_hysteria_config() {
    # Stop the Hysteria2 service
    sudo systemctl stop hysteria2
    
    # Remove the existing configuration
    rm -rf /etc/hysteria2

    # download the server-auto.yaml file
    mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server-auto-warp.yaml

    # Prompt the user to enter a port and replace "PORT" in the server.yaml file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/hysteria2/server.yaml

    # Prompt the user to enter a domain and replace "DOMAIN" in the server.yaml file
    read -p "Please enter your domain: " user_domain
    sed -i "s/DOMAIN/$user_domain/" /etc/hysteria2/server.yaml

    # Prompt the user to enter a password and replace "PASSWORD" in the server.yaml file
    read -s -p "Please enter your password: " user_password
    echo
    sed -i "s/PASSWORD/$user_password/" /etc/hysteria2/server.yaml

    # Prompt the user to enter an email and replace "EMAIL" in the server.yaml file
    read -p "Please enter your email: " user_email
    sed -i "s/EMAIL/$user_email/" /etc/hysteria2/server.yaml

    # Execute the WARP setup script (with user key replacement)
    bash <(curl -fsSL git.io/warp.sh) proxy

    # Prompt the user for their WARP+ key
    read -p "Enter your WARP+ key: " warp_key

    # Replace the placeholder in the command and run it
    warp_command="warp-cli set-license $warp_key"
    eval "$warp_command"

    # Restart WARP
    bash <(curl -fsSL git.io/warp.sh) restart
    
    # Enable and start the Hysteria2 service
    sudo systemctl enable hysteria2
    sudo systemctl start hysteria2
    
    # Use a public DNS service to determine the public IP address
    public_ip=$(curl -s https://ipinfo.io/ip)

    # Construct and display the resulting URL
    result_url="hy2://$user_password@$public_ip:$user_port?insecure=1&sni=$user_domain#HY2"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL

    echo "Hysteria configuration modified."
    
    exit 0  # Exit the script immediately with a successful status
}

# Function to uninstall Hysteria
uninstall_hysteria() {
    # Stop the Hysteria2 service
    sudo systemctl stop hysteria2

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/hysteria2
    rm -rf /etc/hysteria2
    sudo rm -f /etc/systemd/system/hysteria2.service
    
    # Uninstall warp client
    bash <(curl -fsSL git.io/warp.sh) uninstall

    echo "Hysteria uninstalled."

    exit 0  # Exit the script immediately with a successful status
}

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
            modify_hysteria_config
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
