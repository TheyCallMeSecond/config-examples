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
    
    # Step 8: Use a public DNS service to determine the public IP address
    public_ip=$(curl -s https://ipinfo.io/ip)
    
    # Step 9:Execute the WARP setup script (with user key replacement)
    bash <(curl -fsSL git.io/warp.sh) proxy

    # Step 10:Prompt the user for their WARP+ key
    read -p "Enter your WARP+ key: " warp_key

    # Step 11:Replace the placeholder in the command and run it
    warp_command="warp-cli set-license $warp_key"
    eval "$warp_command"

    # Step 12:Restart WARP
    bash <(curl -fsSL git.io/warp.sh) restart

    # Step 13: Enable and start the Hysteria2 service
    sudo systemctl enable hysteria2
    sudo systemctl start hysteria2

    # Step 14:Construct and display the resulting URL
    result_url="hy2://$user_password@$public_ip:$user_port?insecure=1&sni=$user_domain#HY2"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL

    echo "Hysteria setup completed."
    
    exit 0  # Exit the script immediately with a successful status
}

# Function to modify Hysteria configuration
modify_hysteria_config() {
    file_to_check="/etc/hysteria2/server.yaml"
    if [ -e "$file_to_check" ]; then
    
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
    
    # Use a public DNS service to determine the public IP address
    public_ip=$(curl -s https://ipinfo.io/ip)

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

    # Construct and display the resulting URL
    result_url="hy2://$user_password@$public_ip:$user_port?insecure=1&sni=$user_domain#HY2"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL

    echo "Hysteria configuration modified."
    
    else
    echo "Hysteria is not installed yet."
    
    fi
    
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

    echo "Hysteria uninstalled."

    exit 0  # Exit the script immediately with a successful status
}

install_tuic() {
    # Download tuic binary and make it executable
    curl -Lo /root/tuic https://github.com/EAimTY/tuic/releases/download/tuic-server-1.0.0/tuic-server-1.0.0-x86_64-unknown-linux-gnu && chmod +x /root/tuic && mv -f /root/tuic /usr/bin

    # Create a directory for tuic configuration and download the server.json file
    mkdir -p /etc/tuic && curl -Lo /etc/tuic/server.json https://github.com/TheyCallMeSecond/config-examples/raw/main/TUIC/server.json

    # download the tuic.service file
    curl -Lo /etc/systemd/system/tuic.service https://github.com/TheyCallMeSecond/config-examples/raw/main/TUIC/tuic.service && systemctl daemon-reload

    # Prompt the user to enter a port and replace "PORT" in the server.json file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/tuic/server.json

    # get certificate
    mkdir /root/cert && cd /root/cert
    
    openssl genrsa -out ca.key 2048

    openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=Apple Root CA" -out ca.crt

    openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=*.apple.com" -out server.csr

    openssl x509 -req -extfile <(printf "subjectAltName=DNS:apple.com,DNS:www.apple.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
    
    mv server.crt /etc/tuic/server.crt
    
    mv server.key /etc/tuic/server.key
    
    cd
    
    rm -rf /root/cert

    # generate a password and replace "PASSWORD" in the server.json file
    password:$(openssl rand -hex 8)
    sed -i "s/PASSWORD/$password/" /etc/tuic/server.json

    # generate uuid and replace "UUID" in the server.json file
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/UUID/$uuid/" /etc/tuic/server.json
    
    # Use a public DNS service to determine the public IP address
    public_ip=$(curl -s https://ipinfo.io/ip)

    # Enable and start the tuic service
    sudo systemctl enable --now tuic

    # Construct and display the resulting URL
    result_url="tuic://$uuid:$password@$public_ip:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC-V5"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL

    echo "tuic setup completed."
    
    exit 0  # Exit the script immediately with a successful status
}

    # Function to modify tuic configuration
 modify_tuic_config() {
     file_to_check="/etc/tuic/server.json"
    if [ -e "$file_to_check" ]; then
    
    # Stop the tuic service
    sudo systemctl stop tuic
    
    # Remove the existing configuration
    rm -rf /etc/tuic
    
    # Create a directory for tuic configuration and download the server.json file
    mkdir -p /etc/tuic && curl -Lo /etc/tuic/server.json https://github.com/TheyCallMeSecond/config-examples/raw/main/TUIC/server.json
    
    # Prompt the user to enter a port and replace "PORT" in the server.json file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/tuic/server.json

    # get certificate
    mkdir /root/cert && cd /root/cert
    
    openssl genrsa -out ca.key 2048

    openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=Apple Root CA" -out ca.crt

    openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=*.apple.com" -out server.csr

    openssl x509 -req -extfile <(printf "subjectAltName=DNS:apple.com,DNS:www.apple.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
    
    mv server.crt /etc/tuic/server.crt
    
    mv server.key /etc/tuic/server.key
    
    cd
    
    rm -rf /root/cert

    # generate a password and replace "PASSWORD" in the server.json file
    password:$(openssl rand -hex 8)
    sed -i "s/PASSWORD/$password/" /etc/tuic/server.json

    # generate uuid and replace "UUID" in the server.json file
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/UUID/$uuid/" /etc/tuic/server.json
    
    # Use a public DNS service to determine the public IP address
    public_ip=$(curl -s https://ipinfo.io/ip)

    # Enable and start the tuic service
    sudo systemctl enable --now tuic

    # Construct and display the resulting URL
    result_url="tuic://$uuid:$password@$public_ip:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC-V5"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL

    echo "tuic configuration modified."
    
    else
    echo "tuic is not installed yet."
    
    fi
    
    exit 0  # Exit the script immediately with a successful status
}
    
    # Function to uninstall tuic
uninstall_tuic() {
    # Stop the tuic service
    sudo systemctl stop tuic

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/tuic
    rm -rf /etc/tuic
    sudo rm -f /etc/systemd/system/tuic.service

    echo "tuic uninstalled."

    exit 0  # Exit the script immediately with a successful status
}

install_reality() {
    # Download sing-box binary and make it executable
    mkdir /root/singbox && cd /root/singbox
    wget https://github.com/SagerNet/sing-box/releases/download/v1.4.3/sing-box-1.4.3-linux-amd64.tar.gz
    tar xvzf sing-box-1.4.3-linux-amd64.tar.gz
    cd sing-box-1.4.3-linux-amd64
    mv -f sing-box /usr/bin
    cd && rm -rf singbox

    # Create a directory for sing-box configuration and download the Reality-gRPC.json file
    mkdir -p /etc/sing-box && curl -Lo /etc/sing-box/config.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/Reality-gRPC+warp.json

    # download the sing-box.service file
    curl -Lo /etc/systemd/system/sing-box.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/sing-box.service && systemctl daemon-reload

    # Prompt the user to enter a port and replace "PORT" in the config.json file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/sing-box/config.json

    # Prompt the user to enter a sni and replace "SNI" in the config.json file
    read -p "Please enter sni: " user_sni
    sed -i "s/SNI/$user_sni/" /etc/sing-box/config.json

    # generate uuid and replace "UUID" in the config.json file
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/UUID/$uuid/" /etc/sing-box/config.json
    
    # generate reality key-pair
    output=$(sing-box generate reality-keypair)
    
    private_key=$(echo "$output" | grep -oP 'PrivateKey: \K\S+')
    public_key=$(echo "$output" | grep -oP 'PublicKey: \K\S+')
    
    sed -i "s/PRIVATE-KEY/$private_key/" /etc/sing-box/config.json
    
    # generate short id
    short_id:$(openssl rand -hex 8)
    sed -i "s/SHORT-ID/$short_id/" /etc/sing-box/config.json
    
    # generate service name
    service_name:$(openssl rand -hex 4)
    sed -i "s/SERVICE-NAME/$service_name/" /etc/sing-box/config.json
    
    # Use a public DNS service to determine the public IP address
    public_ip=$(curl -s https://ipinfo.io/ip)

    # Execute the WARP setup script (with user key replacement)
    bash <(curl -fsSL git.io/warp.sh) proxy

    # Prompt the user for their WARP+ key
    read -p "Enter your WARP+ key: " warp_key

    # Replace the placeholder in the command and run it
    warp_command="warp-cli set-license $warp_key"
    eval "$warp_command"

    # Restart WARP
    bash <(curl -fsSL git.io/warp.sh) restart

    # Enable and start the sing-box service
    sudo systemctl enable --now sing-box

    # Construct and display the resulting URL
    result_url="vless://$uuid@$public_ip:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL

    echo "Reality setup completed."
    
    exit 0  # Exit the script immediately with a successful status
}

    # Function to modify reality configuration
    modify_reality_config() {
    file_to_check="/etc/sing-box/config.json"
    if [ -e "$file_to_check" ]; then

    # Stop the sing-box service
    sudo systemctl stop sing-box    
    
    # Remove the existing configuration
    rm -rf /etc/sing-box
    
    # Create a directory for sing-box configuration and download the config.json file
    mkdir -p /etc/sing-box && curl -Lo /etc/sing-box/config.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/Reality-gRPC+warp.json
    
    # Prompt the user to enter a port and replace "PORT" in the config.json file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/sing-box/config.json

    # Prompt the user to enter a sni and replace "SNI" in the config.json file
    read -p "Please enter sni: " user_sni
    sed -i "s/SNI/$user_sni/" /etc/sing-box/config.json

    # generate uuid and replace "UUID" in the config.json file
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/UUID/$uuid/" /etc/sing-box/config.json
    
    # generate reality key-pair
    output=$(sing-box generate reality-keypair)
    
    private_key=$(echo "$output" | grep -oP 'PrivateKey: \K\S+')
    public_key=$(echo "$output" | grep -oP 'PublicKey: \K\S+')
    
    sed -i "s/PRIVATE-KEY/$private_key/" /etc/sing-box/config.json
    
    # generate short id
    short_id:$(openssl rand -hex 8)
    sed -i "s/SHORT-ID/$short_id/" /etc/sing-box/config.json
    
    # generate service name
    service_name:$(openssl rand -hex 4)
    sed -i "s/SERVICE-NAME/$service_name/" /etc/sing-box/config.json
    
    # Use a public DNS service to determine the public IP address
    public_ip=$(curl -s https://ipinfo.io/ip)
    
    # Prompt the user for their WARP+ key
    read -p "Enter your WARP+ key: " warp_key

    # Replace the placeholder in the command and run it
    warp_command="warp-cli set-license $warp_key"
    eval "$warp_command"
    
    # Restart WARP
    bash <(curl -fsSL git.io/warp.sh) restart   

    # Enable and start the sing-box service
    sudo systemctl enable --now sing-box

    # Construct and display the resulting URL
    result_url="vless://$uuid@$public_ip:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality"
    echo -e "Config URL: \e[91m$result_url\e[0m"  # Red color for URL

    echo "Reality configuration modified."
    
    else
    echo "Reality is not installed yet."
    
    fi
    
    exit 0  # Exit the script immediately with a successful status
}

# Function to uninstall reality
uninstall_reality() {
    # Stop the sing-box service
    sudo systemctl stop sing-box

    # Remove sing-box binary, configuration, and service file
    sudo rm -f /usr/bin/sing-box
    rm -rf /etc/sing-box
    sudo rm -f /etc/systemd/system/sing-box.service

    echo "Reality uninstalled."

    exit 0  # Exit the script immediately with a successful status
}

# Function to uninstall warp    
uninstall_warp() {
    # Uninstall warp client
    bash <(curl -fsSL git.io/warp.sh) uninstall
    
    echo "warp uninstalled."

    exit 0  # Exit the script immediately with a successful status
} 

# Main menu loop
while true; do
    echo -e "Please select an option:"
    echo -e "1: \e[93mInstall Hysteria\e[0m"
    echo -e "2: \e[93mModify Hysteria Config\e[0m"
    echo -e "3: \e[93mUninstall Hysteria\e[0m"
    echo -e "4: \e[93mInstall tuic\e[0m"
    echo -e "5: \e[93mModify tuic Config\e[0m"
    echo -e "6: \e[93mUninstall tuic\e[0m"
    echo -e "7: \e[93mInstall reality\e[0m"
    echo -e "8: \e[93mModify reality Config\e[0m"
    echo -e "9: \e[93mUninstall reality\e[0m"
    echo -e "10: \e[93mUninstall warp\e[0m"    
    echo -e "0: \e[93mExit\e[0m"

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
            install_tuic
            ;;
        5)
            modify_tuic_config
            ;;
        6)
            uninstall_tuic
            ;;
        7)
            install_reality
            ;;
        8)
            modify_reality_config
            ;;
        9)
            uninstall_reality
            ;;
        10)
            uninstall_warp
            ;;            
        0)
            echo "Exiting."
            exit 0  # Exit the script immediately
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
done
