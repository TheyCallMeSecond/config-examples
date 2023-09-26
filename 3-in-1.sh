#!/bin/bash

# Function to install Hysteria
install_hysteria() {
    apt update && apt install -y qrencode

    # Download Hysteria binary and make it executable
    curl -Lo /root/hysteria2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && chmod +x /root/hysteria2 && mv -f /root/hysteria2 /usr/bin

    # Create a directory for Hysteria configuration and download the server.yaml file
    mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server-auto-warp.yaml

    # Download the hysteria2.service file
    curl -Lo /etc/systemd/system/hysteria2.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/hysteria2.service && systemctl daemon-reload

    # Prompt the user to enter a port and replace "PORT" in the server.yaml file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/hysteria2/server.yaml

    # Prompt the user to enter a domain and replace "DOMAIN" in the server.yaml file
    read -p "Please enter your domain: " user_domain
    sed -i "s/DOMAIN/$user_domain/" /etc/hysteria2/server.yaml

    # Generate a password and replace "PASSWORD" in the server.yaml file
    password=$(openssl rand -hex 8)
    sed -i "s/PASSWORD/$password/" /etc/hysteria2/server.yaml

    # Prompt the user to enter an email and replace "EMAIL" in the server.yaml file
    read -p "Please enter your email: " user_email
    sed -i "s/EMAIL/$user_email/" /etc/hysteria2/server.yaml

    # Use a public DNS service to determine the public IP address
    public_ipv4=$(curl -s https://v4.ident.me)
    public_ipv6=$(curl -s https://v6.ident.me)

    # WARP+ installation
    warp_check="/lib/systemd/system/warp-svc.service"

    if [ -e "$warp_check" ]; then

        echo "WARP is running."

    else

        # Execute the WARP setup script (with user key replacement)
        bash <(curl -fsSL git.io/warp.sh) proxy

        # Prompt the user for their WARP+ key
        read -p "Enter your WARP+ key: " warp_key

        # Replace the placeholder in the command and run it
        warp_command="warp-cli set-license $warp_key"
        eval "$warp_command"

        # Restart WARP
        bash <(curl -fsSL git.io/warp.sh) restart

    fi

    # Enable and start the Hysteria2 service
    sudo systemctl enable hysteria2
    sudo systemctl start hysteria2

    # Construct and display the resulting URL & QR
    result_url=" 
    ipv4 : hy2://$password@$public_ipv4:$user_port?insecure=1&sni=$user_domain#HY2
    ---------------------------------------------------------------
    ipv6 : hy2://$password@[$public_ipv6]:$user_port?insecure=1&sni=$user_domain#HY2"
    echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/hysteria2/config.txt # Red color for URL

    cat /etc/hysteria2/config.txt

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/hysteria2/config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/hysteria2/config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"

    echo "Hysteria2 setup completed."

    exit 0 # Exit the script immediately with a successful status
}

# Function to modify Hysteria configuration
modify_hysteria_config() {
    hysteria_check="/etc/hysteria2/server.yaml"

    if [ -e "$hysteria_check" ]; then

        # Stop the Hysteria2 service
        sudo systemctl stop hysteria2

        # Remove the existing configuration
        rm -rf /etc/hysteria2

        # Download the server-auto.yaml file
        mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server-auto-warp.yaml

        # Prompt the user to enter a port and replace "PORT" in the server.yaml file
        read -p "Please enter a port: " user_port
        sed -i "s/PORT/$user_port/" /etc/hysteria2/server.yaml

        # Prompt the user to enter a domain and replace "DOMAIN" in the server.yaml file
        read -p "Please enter your domain: " user_domain
        sed -i "s/DOMAIN/$user_domain/" /etc/hysteria2/server.yaml

        # Generate a password and replace "PASSWORD" in the server.yaml file
        password=$(openssl rand -hex 8)
        sed -i "s/PASSWORD/$password/" /etc/hysteria2/server.yaml

        # Prompt the user to enter an email and replace "EMAIL" in the server.yaml file
        read -p "Please enter your email: " user_email
        sed -i "s/EMAIL/$user_email/" /etc/hysteria2/server.yaml

        # Use a public DNS service to determine the public IP address
        public_ipv4=$(curl -s https://v4.ident.me)
        public_ipv6=$(curl -s https://v6.ident.me)

        # Enable and start the Hysteria2 service
        sudo systemctl enable hysteria2
        sudo systemctl start hysteria2

        # Construct and display the resulting URL
        result_url=" 
        ipv4 : hy2://$password@$public_ipv4:$user_port?insecure=1&sni=$user_domain#HY2
        ---------------------------------------------------------------
        ipv6 : hy2://$password@[$public_ipv6]:$user_port?insecure=1&sni=$user_domain#HY2"
        echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/hysteria2/config.txt # Red color for URL

        cat /etc/hysteria2/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/hysteria2/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/hysteria2/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

        echo "Hysteria2 configuration modified."

    else

        echo "Hysteria2 is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to uninstall Hysteria
uninstall_hysteria() {
    # Stop the Hysteria2 service
    sudo systemctl stop hysteria2

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/hysteria2
    rm -rf /etc/hysteria2
    sudo rm -f /etc/systemd/system/hysteria2.service

    echo "Hysteria2 uninstalled."

    exit 0 # Exit the script immediately with a successful status
}

install_tuic() {
    apt update && apt install -y qrencode

    # Download tuic binary and make it executable
    curl -Lo /root/tuic https://github.com/EAimTY/tuic/releases/download/tuic-server-1.0.0/tuic-server-1.0.0-x86_64-unknown-linux-gnu && chmod +x /root/tuic && mv -f /root/tuic /usr/bin

    # Create a directory for tuic configuration and download the server.json file
    mkdir -p /etc/tuic && curl -Lo /etc/tuic/server.json https://github.com/TheyCallMeSecond/config-examples/raw/main/TUIC/server.json

    # Download the tuic.service file
    curl -Lo /etc/systemd/system/tuic.service https://github.com/TheyCallMeSecond/config-examples/raw/main/TUIC/tuic.service && systemctl daemon-reload

    # Prompt the user to enter a port and replace "PORT" in the server.json file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/tuic/server.json

    # Get certificate
    mkdir /root/cert && cd /root/cert || exit

    openssl genrsa -out ca.key 2048

    openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=Apple Root CA" -out ca.crt

    openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=*.apple.com" -out server.csr

    openssl x509 -req -extfile <(printf "subjectAltName=DNS:apple.com,DNS:www.apple.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

    mv server.crt /etc/tuic/server.crt

    mv server.key /etc/tuic/server.key

    cd || exit

    rm -rf /root/cert

    # Generate a password and replace "PASSWORD" in the server.json file
    password=$(openssl rand -hex 8)
    sed -i "s/PASSWORD/$password/" /etc/tuic/server.json

    # Generate uuid and replace "UUID" in the server.json file
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/UUID/$uuid/" /etc/tuic/server.json

    # Use a public DNS service to determine the public IP address
    public_ipv4=$(curl -s https://v4.ident.me)
    public_ipv6=$(curl -s https://v6.ident.me)

    # Enable and start the tuic service
    sudo systemctl enable --now tuic

    # Construct and display the resulting URL
    result_url=" 
    ipv4 : tuic://$uuid:$password@$public_ipv4:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC
    ---------------------------------------------------------------
    ipv6 : tuic://$uuid:$password@[$public_ipv6]:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC"
    echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/tuic/config.txt # Red color for URL

    cat /etc/tuic/config.txt

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/tuic/config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/tuic/config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"

    echo "TUIC setup completed."

    exit 0 # Exit the script immediately with a successful status
}

# Function to modify tuic configuration
modify_tuic_config() {
    tuic_check="/etc/tuic/server.json"

    if [ -e "$tuic_check" ]; then

        # Stop the tuic service
        sudo systemctl stop tuic

        # Remove the existing configuration
        rm -rf /etc/tuic

        # Create a directory for tuic configuration and download the server.json file
        mkdir -p /etc/tuic && curl -Lo /etc/tuic/server.json https://github.com/TheyCallMeSecond/config-examples/raw/main/TUIC/server.json

        # Prompt the user to enter a port and replace "PORT" in the server.json file
        read -p "Please enter a port: " user_port
        sed -i "s/PORT/$user_port/" /etc/tuic/server.json

        # Get certificate
        mkdir /root/cert && cd /root/cert || exit

        openssl genrsa -out ca.key 2048

        openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=Apple Root CA" -out ca.crt

        openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=*.apple.com" -out server.csr

        openssl x509 -req -extfile <(printf "subjectAltName=DNS:apple.com,DNS:www.apple.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

        mv server.crt /etc/tuic/server.crt

        mv server.key /etc/tuic/server.key

        cd || exit

        rm -rf /root/cert

        # Generate a password and replace "PASSWORD" in the server.json file
        password=$(openssl rand -hex 8)
        sed -i "s/PASSWORD/$password/" /etc/tuic/server.json

        # Generate uuid and replace "UUID" in the server.json file
        uuid=$(cat /proc/sys/kernel/random/uuid)
        sed -i "s/UUID/$uuid/" /etc/tuic/server.json

        # Use a public DNS service to determine the public IP address
        public_ipv4=$(curl -s https://v4.ident.me)
        public_ipv6=$(curl -s https://v6.ident.me)

        # Enable and start the tuic service
        sudo systemctl enable --now tuic

        # Construct and display the resulting URL
        result_url=" 
        ipv4 : tuic://$uuid:$password@$public_ipv4:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC
        ---------------------------------------------------------------
        ipv6 : tuic://$uuid:$password@[$public_ipv6]:$user_port?congestion_control=bbr&alpn=h3,%20spdy/3.1&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC"
        echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/tuic/config.txt # Red color for URL

        cat /etc/tuic/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/tuic/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/tuic/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

        echo "TUIC configuration modified."

    else

        echo "TUIC is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to uninstall tuic
uninstall_tuic() {
    # Stop the tuic service
    sudo systemctl stop tuic

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/tuic
    rm -rf /etc/tuic
    sudo rm -f /etc/systemd/system/tuic.service

    echo "TUIC uninstalled."

    exit 0 # Exit the script immediately with a successful status
}

install_reality() {
    apt update && apt install -y qrencode

    # Download sing-box binary
    mkdir /root/singbox && cd /root/singbox || exit
    wget https://github.com/SagerNet/sing-box/releases/download/v1.4.5/sing-box-1.4.5-linux-amd64.tar.gz
    tar xvzf sing-box-1.4.5-linux-amd64.tar.gz
    cd sing-box-1.4.5-linux-amd64 || exit
    mv -f sing-box /usr/bin
    cd && rm -rf singbox

    # Create a directory for sing-box configuration and download the Reality-gRPC.json file
    mkdir -p /etc/sing-box && curl -Lo /etc/sing-box/config.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/Reality-gRPC+warp.json

    # Download the sing-box.service file
    curl -Lo /etc/systemd/system/sing-box.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/sing-box.service && systemctl daemon-reload

    # Prompt the user to enter a port and replace "PORT" in the config.json file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/sing-box/config.json

    # Prompt the user to enter a sni and replace "SNI" in the config.json file
    read -p "Please enter sni: " user_sni
    sed -i "s/SNI/$user_sni/" /etc/sing-box/config.json

    # Generate uuid and replace "UUID" in the config.json file
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/UUID/$uuid/" /etc/sing-box/config.json

    # Generate reality key-pair
    output=$(sing-box generate reality-keypair)

    private_key=$(echo "$output" | grep -oP 'PrivateKey: \K\S+')
    public_key=$(echo "$output" | grep -oP 'PublicKey: \K\S+')

    sed -i "s/PRIVATE-KEY/$private_key/" /etc/sing-box/config.json

    # Generate short id
    short_id=$(openssl rand -hex 8)
    sed -i "s/SHORT-ID/$short_id/" /etc/sing-box/config.json

    # Generate service name
    service_name=$(openssl rand -hex 4)
    sed -i "s/SERVICE-NAME/$service_name/" /etc/sing-box/config.json

    # Use a public DNS service to determine the public IP address
    public_ipv4=$(curl -s https://v4.ident.me)
    public_ipv6=$(curl -s https://v6.ident.me)

    # WARP+ installation
    warp_check="/lib/systemd/system/warp-svc.service"

    if [ -e "$warp_check" ]; then

        echo "WARP is running."

    else

        # Execute the WARP setup script (with user key replacement)
        bash <(curl -fsSL git.io/warp.sh) proxy

        # Prompt the user for their WARP+ key
        read -p "Enter your WARP+ key: " warp_key

        # Replace the placeholder in the command and run it
        warp_command="warp-cli set-license $warp_key"
        eval "$warp_command"

        # Restart WARP
        bash <(curl -fsSL git.io/warp.sh) restart

    fi

    # Enable and start the sing-box service
    sudo systemctl enable --now sing-box

    # Construct and display the resulting URL
    result_url=" 
    ipv4 : vless://$uuid@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality
    ---------------------------------------------------------------
    ipv6 : vless://$uuid@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality"
    echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/sing-box/config.txt # Red color for URL

    cat /etc/sing-box/config.txt

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/sing-box/config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/sing-box/config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"
    echo "Reality setup completed."

    exit 0 # Exit the script immediately with a successful status
}

# Function to modify reality configuration
modify_reality_config() {
    reality_check="/etc/sing-box/config.json"

    if [ -e "$reality_check" ]; then

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

        # Generate uuid and replace "UUID" in the config.json file
        uuid=$(cat /proc/sys/kernel/random/uuid)
        sed -i "s/UUID/$uuid/" /etc/sing-box/config.json

        # Generate reality key-pair
        output=$(sing-box generate reality-keypair)

        private_key=$(echo "$output" | grep -oP 'PrivateKey: \K\S+')
        public_key=$(echo "$output" | grep -oP 'PublicKey: \K\S+')

        sed -i "s/PRIVATE-KEY/$private_key/" /etc/sing-box/config.json

        # Generate short id
        short_id=$(openssl rand -hex 8)
        sed -i "s/SHORT-ID/$short_id/" /etc/sing-box/config.json

        # Generate service name
        service_name=$(openssl rand -hex 4)
        sed -i "s/SERVICE-NAME/$service_name/" /etc/sing-box/config.json

        # Use a public DNS service to determine the public IP address
        public_ipv4=$(curl -s https://v4.ident.me)
        public_ipv6=$(curl -s https://v6.ident.me)

        # Enable and start the sing-box service
        sudo systemctl enable --now sing-box

        # Construct and display the resulting URL
        result_url=" 
        ipv4 : vless://$uuid@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality
        ---------------------------------------------------------------
        ipv6 : vless://$uuid@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality"
        echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/sing-box/config.txt # Red color for URL

        cat /etc/sing-box/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/sing-box/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/sing-box/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

        echo "Reality configuration modified."

    else

        echo "Reality is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
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

    exit 0 # Exit the script immediately with a successful status
}

install_shadowtls() {
    apt update && apt install -y qrencode

    # Download sing-box binary
    mkdir /root/singbox && cd /root/singbox || exit
    wget https://github.com/SagerNet/sing-box/releases/download/v1.4.5/sing-box-1.4.5-linux-amd64.tar.gz
    tar xvzf sing-box-1.4.5-linux-amd64.tar.gz
    cd sing-box-1.4.5-linux-amd64 || exit
    mv -f sing-box /usr/bin/ST
    cd && rm -rf singbox

    # Create a directory for shadowtls configuration and download the ShadowTLS.json file
    mkdir -p /etc/shadowtls && curl -Lo /etc/shadowtls/config.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/ShadowTLS-warp.json

    # Download client config files
    curl -Lo /etc/shadowtls/nekorayconfig.txt https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Client/ShadowTLS-nekoray.json
    curl -Lo /etc/shadowtls/nekoboxconfig.txt https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Client/ShadowTLS-nekobox.json

    # Download the ST.service file
    curl -Lo /etc/systemd/system/ST.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/ST.service && systemctl daemon-reload

    # Prompt the user to enter a port and replace "PORT" in the config files
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/shadowtls/config.json
    sed -i "s/PORT/$user_port/" /etc/shadowtls/nekorayconfig.txt
    sed -i "s/PORT/$user_port/" /etc/shadowtls/nekoboxconfig.txt

    # Prompt the user to enter a sni and replace "SNI" in the config files
    read -p "Please enter sni: " user_sni
    sed -i "s/SNI/$user_sni/" /etc/shadowtls/config.json
    sed -i "s/SNI/$user_sni/" /etc/shadowtls/nekorayconfig.txt
    sed -i "s/SNI/$user_sni/" /etc/shadowtls/nekoboxconfig.txt    

    # Generate  name
    name=$(openssl rand -hex 4)
    sed -i "s/NAME/$name/" /etc/shadowtls/config.json

    # Generate a password and replace "PASSWORD" in the config files
    password=$(openssl rand -base64 24)
    sed -i "s/PASSWORD/$password/" /etc/shadowtls/config.json
    sed -i "s/PASSWORD/$password/" /etc/shadowtls/nekorayconfig.txt
    sed -i "s/PASSWORD/$password/" /etc/shadowtls/nekoboxconfig.txt

    # Generate a password and replace "PASSWORD2" in the config files
    password2=$(openssl rand -base64 24)
    sed -i "s/PASSWORD2/$password2/" /etc/shadowtls/config.json
    sed -i "s/PASSWORD2/$password2/" /etc/shadowtls/nekorayconfig.txt
    sed -i "s/PASSWORD2/$password2/" /etc/shadowtls/nekoboxconfig.txt

    # Use a public DNS service to determine the public IP address and replace with IP in config.txt file
    public_ipv4=$(curl -s https://v4.ident.me)
    sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekorayconfig.txt
    sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekoboxconfig.txt

    # WARP+ installation
    warp_check="/lib/systemd/system/warp-svc.service"

    if [ -e "$warp_check" ]; then

        echo "WARP is running."

    else

        # Execute the WARP setup script (with user key replacement)
        bash <(curl -fsSL git.io/warp.sh) proxy

        # Prompt the user for their WARP+ key
        read -p "Enter your WARP+ key: " warp_key

        # Replace the placeholder in the command and run it
        warp_command="warp-cli set-license $warp_key"
        eval "$warp_command"

        # Restart WARP
        bash <(curl -fsSL git.io/warp.sh) restart

    fi

    # Enable and start the ST service
    sudo systemctl enable --now ST

    # Display the resulting config

    echo "ShadowTLS config for Nekoray : "

    cat /etc/shadowtls/nekorayconfig.txt

    echo "ShadowTLS config for Nekobox : "

    nekobox=$(cat /etc/shadowtls/nekoboxconfig.txt)

    qrencode -t ANSIUTF8 <<<"$nekobox"

    echo "ShadowTLS setup completed."

    exit 0 # Exit the script immediately with a successful status
}

# Function to modify shadowtls configuration
modify_shadowtls_config() {
    shadowtls_check="/etc/shadowtls/config.json"

    if [ -e "$shadowtls_check" ]; then

        # Stop the sing-box service
        sudo systemctl stop ST

        # Remove the existing configuration
        rm -rf /etc/shadowtls

        # Create a directory for shadowtls configuration and download the ShadowTLS.json file
        mkdir -p /etc/shadowtls && curl -Lo /etc/shadowtls/config.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/ShadowTLS-warp.json

        # Download client config files
        curl -Lo /etc/shadowtls/nekorayconfig.txt https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Client/ShadowTLS-nekoray.json
        curl -Lo /etc/shadowtls/nekoboxconfig.txt https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Client/ShadowTLS-nekobox.json

        # Prompt the user to enter a port and replace "PORT" in the config files
        read -p "Please enter a port: " user_port
        sed -i "s/PORT/$user_port/" /etc/shadowtls/config.json
        sed -i "s/PORT/$user_port/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/PORT/$user_port/" /etc/shadowtls/nekoboxconfig.txt

        # Prompt the user to enter a sni and replace "SNI" in the config files
        read -p "Please enter sni: " user_sni
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/config.json
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/SNI/$user_sni/" /etc/shadowtls/nekoboxconfig.txt

        # Generate  name
        name=$(openssl rand -hex 4)
        sed -i "s/NAME/$name/" /etc/shadowtls/config.json

        # Generate a password and replace "PASSWORD" in the config files
        password=$(openssl rand -base64 24)
        sed -i "s/PASSWORD/$password/" /etc/shadowtls/config.json
        sed -i "s/PASSWORD/$password/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/PASSWORD/$password/" /etc/shadowtls/nekoboxconfig.txt

        # Generate a password and replace "PASSWORD2" in the config files
        password2=$(openssl rand -base64 24)
        sed -i "s/PASSWORD2/$password2/" /etc/shadowtls/config.json
        sed -i "s/PASSWORD2/$password2/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/PASSWORD2/$password2/" /etc/shadowtls/nekoboxconfig.txt

        # Use a public DNS service to determine the public IP address and replace with IP in config.txt file
        public_ipv4=$(curl -s https://v4.ident.me)
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekoboxconfig.txt

        # start the ST service
        sudo systemctl start ST

        # Display the resulting config

        echo "ShadowTLS config for Nekoray : "

        cat /etc/shadowtls/nekorayconfig.txt

        echo "ShadowTLS config for Nekobox : "

        nekobox=$(cat /etc/shadowtls/nekoboxconfig.txt)

        qrencode -t ANSIUTF8 <<<"$nekobox"

        echo "ShadowTLS configuration modified."

    else

        echo "ShadowTLS is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to uninstall shadowtls
uninstall_shadowtls() {
    # Stop the ST service
    sudo systemctl stop ST

    # Remove sing-box binary, configuration, and service file
    sudo rm -f /usr/bin/ST
    rm -rf /etc/shadowtls
    sudo rm -f /etc/systemd/system/ST.service

    echo "ShadowTLS uninstalled."

    exit 0 # Exit the script immediately with a successful status
}

# Function to show hysteria config
show_hysteria_config() {
    hysteria_check="/etc/hysteria2/config.txt"

    if [ -e "$hysteria_check" ]; then

        cat /etc/hysteria2/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/hysteria2/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/hysteria2/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

    else

        echo "Hysteria2 is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to show tuic config
show_tuic_config() {
    tuic_check="/etc/tuic/config.txt"

    if [ -e "$tuic_check" ]; then

        cat /etc/tuic/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/tuic/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/tuic/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

    else

        echo "TUIC is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to show reality config
show_reality_config() {
    reality_check="/etc/sing-box/config.txt"

    if [ -e "$reality_check" ]; then

        cat /etc/sing-box/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/sing-box/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/sing-box/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

    else

        echo "Reality is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to show shadowtls config
show_shadowtls_config() {
    shadowtls_check="/etc/shadowtls/nekorayconfig.txt"

    if [ -e "$shadowtls_check" ]; then

        echo "ShadowTLS config for Nekoray : "

        cat /etc/shadowtls/nekorayconfig.txt

        echo "ShadowTLS config for Nekobox : "

        nekobox=$(cat /etc/shadowtls/nekoboxconfig.txt)

        qrencode -t ANSIUTF8 <<<"$nekobox"

    else

        echo "ShadowTLS is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to install warp
install_warp() {
    warp_check="/lib/systemd/system/warp-svc.service"

    if [ -e "$warp_check" ]; then

        echo "WARP is running."

    else

        # Execute the WARP setup script (with user key replacement)
        bash <(curl -fsSL git.io/warp.sh) proxy

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to change warp+ key
change_warp_key() {
    warp_check="/lib/systemd/system/warp-svc.service"

    if [ -e "$warp_check" ]; then

        # Prompt the user for their WARP+ key
        read -p "Enter your WARP+ key: " warp_key

        # Replace the placeholder in the command and run it
        warp_command="warp-cli set-license $warp_key"
        eval "$warp_command"

        # Restart WARP
        bash <(curl -fsSL git.io/warp.sh) restart

    else

        echo "WARP is not running."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to uninstall warp
uninstall_warp() {
    # Uninstall warp client
    bash <(curl -fsSL git.io/warp.sh) uninstall

    echo "WARP uninstalled."

    exit 0 # Exit the script immediately with a successful status
}

# Main menu loop
while true; do
    echo -e "    \e[91mPlease select an option:\e[0m"
    echo -e
    echo -e "1:  \e[93mInstall Hysteria2\e[0m"
    echo -e "2:  \e[93mModify Hysteria2 Config\e[0m"
    echo -e "3:  \e[93mShow Hysteria2 Config\e[0m"
    echo -e "4:  \e[93mUninstall Hysteria2\e[0m"
    echo -------------------------------------------
    echo -e "5:  \e[93mInstall TUIC\e[0m"
    echo -e "6:  \e[93mModify TUIC Config\e[0m"
    echo -e "7:  \e[93mShow TUIC Config\e[0m"
    echo -e "8:  \e[93mUninstall TUIC\e[0m"
    echo -------------------------------------------
    echo -e "9:  \e[93mInstall Reality\e[0m"
    echo -e "10: \e[93mModify Reality Config\e[0m"
    echo -e "11: \e[93mShow Reality Config\e[0m"
    echo -e "12: \e[93mUninstall Reality\e[0m"
    echo -------------------------------------------
    echo -e "13: \e[93mInstall ShadowTLS\e[0m"
    echo -e "14: \e[93mModify ShadowTLS Config\e[0m"
    echo -e "15: \e[93mShow ShadowTLS Config\e[0m"
    echo -e "16: \e[93mUninstall ShadowTLS\e[0m"
    echo -------------------------------------------
    echo -e "17: \e[93mInstall WARP\e[0m"
    echo -e "18: \e[93mSet/Change WARP+ Key\e[0m"
    echo -e "19: \e[93mUninstall WARP\e[0m"
    echo -------------------------------------------
    echo -e "0:  \e[91mExit\e[0m"

    read -p "Enter your choice: " user_choice

    case $user_choice in
    1)
        install_hysteria
        ;;
    2)
        modify_hysteria_config
        ;;
    3)
        show_hysteria_config
        ;;
    4)
        uninstall_hysteria
        ;;
    5)
        install_tuic
        ;;
    6)
        modify_tuic_config
        ;;
    7)
        show_tuic_config
        ;;
    8)
        uninstall_tuic
        ;;
    9)
        install_reality
        ;;
    10)
        modify_reality_config
        ;;
    11)
        show_reality_config
        ;;
    12)
        uninstall_reality
        ;;
    13)
        install_shadowtls
        ;;
    14)
        modify_shadowtls_config
        ;;
    15)
        show_shadowtls_config
        ;;
    16)
        uninstall_shadowtls
        ;;
    17)
        install_warp
        ;;
    18)
        change_warp_key
        ;;
    19)
        uninstall_warp
        ;;
    0)
        echo "Exiting."
        exit 0 # Exit the script immediately
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
    esac
done
