#!/bin/bash

# Function to install Hysteria
install_hysteria() {
    # Step 1: Download Hysteria binary and make it executable
    curl -Lo /root/hysteria2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && chmod +x /root/hysteria2 && mv -f /root/hysteria2 /usr/bin

    # (Previous steps...)
}

# Function to modify config
modify_config() {
    # Stop the Hysteria2 service
    sudo systemctl stop hysteria2

    # Remove the existing configuration
    rm -rf /etc/hysteria2

    # Re-run Step 2 to download the server.yaml file
    mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server.yaml

    # (Continue from Step 4...)
}

# Function to uninstall Hysteria
uninstall_hysteria() {
    # Stop the Hysteria2 service
    sudo systemctl stop hysteria2

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/hysteria2
    rm -rf /etc/hysteria2
    sudo rm -f /etc/systemd/system/hysteria2.service

    echo "Hysteria uninstalled."
    
    exit 0  # Exit the script immediately with a successful status
}

# Main menu loop
while true; do
    echo -e "\e[93mPlease select an option:"
    echo "1: Install"
    echo "2: Modify Config"
    echo "3: Uninstall"
    echo "4: Exit\e[0m"

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


# Step 1: Download Hysteria binary and make it executable
curl -Lo /root/hysteria2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && chmod +x /root/hysteria2 && mv -f /root/hysteria2 /usr/bin

# Step 2: Create a directory for Hysteria configuration and download the server.yaml file
mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server.yaml

# Step 3: download the hysteria2.service file
curl -Lo /etc/systemd/system/hysteria2.service raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/hysteria2.service && systemctl daemon-reload

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

# Step 8: Enable and start the Hysteria2 service
sudo systemctl enable hysteria2
sudo systemctl start hysteria2

# Step 9: Construct and display the resulting URL
result_url="hy2://$user_password@$user_domain:$user_port?insecure=1&sni=$user_domain#HY2"
echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL


echo "Hysteria setup completed."
