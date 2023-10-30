#!/bin/bash

# Function to install Hysteria
install_hysteria() {
    # Stop the Hysteria2 service
    sudo systemctl stop SH

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/SH
    rm -rf /etc/hysteria2
    sudo rm -f /etc/systemd/system/SH.service

    # Download sing-box binary
    mkdir /root/singbox && cd /root/singbox || exit
    LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
    LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
    LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    wget "$LINK"
    tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/SH"
    cd && rm -rf singbox

    # Create a directory for Hysteria configuration and download the server.json file
    mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/Hysteria2.json

    # Download the SH.service file
    curl -Lo /etc/systemd/system/SH.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/SH.service && systemctl daemon-reload

    # Get certificate
    mkdir /root/selfcert && cd /root/selfcert || exit

    openssl genrsa -out ca.key 2048

    openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Google, Inc./CN=Google Root CA" -out ca.crt

    openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Google, Inc./CN=*.google.com" -out server.csr

    openssl x509 -req -extfile <(printf "subjectAltName=DNS:google.com,DNS:www.google.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

    mv server.crt /etc/hysteria2/server.crt

    mv server.key /etc/hysteria2/server.key

    cd || exit

    rm -rf /root/selfcert

    # Prompt the user to enter a port and replace "PORT" in the server.json file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/hysteria2/server.json

    # Generate a password and replace "PASSWORD" in the server.json file
    password=$(openssl rand -hex 8)
    sed -i "s/PASSWORD/$password/" /etc/hysteria2/server.json

    # Generate a name and replace "NAME" in the server.json file
    name=$(openssl rand -hex 4)
    sed -i "s/NAME/$name/" /etc/hysteria2/server.json

    # Use a public DNS service to determine the public IP address
    public_ipv4=$(curl -s https://v4.ident.me)
    public_ipv6=$(curl -s https://v6.ident.me)

    # UFW optimization
    if sudo ufw status | grep -q "Status: active"; then

        # Disable UFW
        sudo ufw disable

        # Open config port
        sudo ufw allow "$user_port"/udp
        sleep 0.5

        # Enable & Reload
        echo "y" | sudo ufw enable
        sudo ufw reload

        echo 'UFW is Optimized.'

        sleep 0.5

    else

        echo "UFW in not active"

    fi

    # Enable and start the SH service
    sudo systemctl enable --now SH

    # Construct and display the resulting URL & QR
    result_url=" 
    ipv4 : hy2://$password@$public_ipv4:$user_port?insecure=1&sni=www.google.com#HY2
    ---------------------------------------------------------------
    ipv6 : hy2://$password@[$public_ipv6]:$user_port?insecure=1&sni=www.google.com#HY2"
    echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/hysteria2/config.txt # Red color for URL

    cat /etc/hysteria2/config.txt

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/hysteria2/config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/hysteria2/config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"

    echo "Hysteria2 setup completed."

    echo -e "\e[31mPress Enter to Exit\e[0m"
    read
    clear
}

# Function to modify Hysteria configuration
modify_hysteria_config() {
    hysteria_check="/etc/hysteria2/server.json"

    if [ -e "$hysteria_check" ]; then

        # Stop the Hysteria2 service
        sudo systemctl stop SH

        # Remove the existing configuration
        rm -rf /etc/hysteria2

        # Create a directory for Hysteria configuration and download the server.json file
        mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/Hysteria2.json

        # Get certificate
        mkdir /root/selfcert && cd /root/selfcert || exit

        openssl genrsa -out ca.key 2048

        openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Google, Inc./CN=Google Root CA" -out ca.crt

        openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Google, Inc./CN=*.google.com" -out server.csr

        openssl x509 -req -extfile <(printf "subjectAltName=DNS:google.com,DNS:www.google.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

        mv server.crt /etc/hysteria2/server.crt

        mv server.key /etc/hysteria2/server.key

        cd || exit

        rm -rf /root/selfcert

        # Prompt the user to enter a port and replace "PORT" in the server.json file
        read -p "Please enter a port: " user_port
        sed -i "s/PORT/$user_port/" /etc/hysteria2/server.json

        # Generate a password and replace "PASSWORD" in the server.json file
        password=$(openssl rand -hex 8)
        sed -i "s/PASSWORD/$password/" /etc/hysteria2/server.json

        # Generate a name and replace "NAME" in the server.json file
        name=$(openssl rand -hex 4)
        sed -i "s/NAME/$name/" /etc/hysteria2/server.json

        # Use a public DNS service to determine the public IP address
        public_ipv4=$(curl -s https://v4.ident.me)
        public_ipv6=$(curl -s https://v6.ident.me)

        # UFW optimization
        if sudo ufw status | grep -q "Status: active"; then

            # Disable UFW
            sudo ufw disable

            # Open config port
            sudo ufw allow "$user_port"/udp
            sleep 0.5

            # Enable & Reload
            echo "y" | sudo ufw enable
            sudo ufw reload

            echo 'UFW is Optimized.'

            sleep 0.5

        else

            echo "UFW in not active"

        fi

        # Start the Hysteria2 service
        sudo systemctl start SH

        # Construct and display the resulting URL
        result_url=" 
        ipv4 : hy2://$password@$public_ipv4:$user_port?insecure=1&sni=www.google.com#HY2
        ---------------------------------------------------------------
        ipv6 : hy2://$password@[$public_ipv6]:$user_port?insecure=1&sni=www.google.com#HY2"
        echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/hysteria2/config.txt # Red color for URL

        cat /etc/hysteria2/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/hysteria2/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/hysteria2/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

        echo "Hysteria2 configuration modified."

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear

    else

        whiptail --msgbox "Hysteria2 is not installed yet." 10 30
        clear

    fi

}

# Function to uninstall Hysteria
uninstall_hysteria() {
    # Stop the Hysteria2 service
    sudo systemctl stop SH

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/SH
    rm -rf /etc/hysteria2
    sudo rm -f /etc/systemd/system/SH.service

    whiptail --msgbox "Hysteria2 uninstalled." 10 30
    clear

}

install_tuic() {
    # Stop the tuic service
    sudo systemctl stop TS

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/TS
    rm -rf /etc/tuic
    sudo rm -f /etc/systemd/system/TS.service

    # Download sing-box binary
    mkdir /root/singbox && cd /root/singbox || exit
    LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
    LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
    LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    wget "$LINK"
    tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/TS"
    cd && rm -rf singbox

    # Create a directory for tuic configuration and download the server.json file
    mkdir -p /etc/tuic && curl -Lo /etc/tuic/server.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/Tuic.json

    # Download the tuic.service file
    curl -Lo /etc/systemd/system/TS.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/TS.service && systemctl daemon-reload

    # Prompt the user to enter a port and replace "PORT" in the server.json file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/tuic/server.json

    # Get certificate
    mkdir /root/selfcert && cd /root/selfcert || exit

    openssl genrsa -out ca.key 2048

    openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=Apple Root CA" -out ca.crt

    openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=*.apple.com" -out server.csr

    openssl x509 -req -extfile <(printf "subjectAltName=DNS:apple.com,DNS:www.apple.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

    mv server.crt /etc/tuic/server.crt

    mv server.key /etc/tuic/server.key

    cd || exit

    rm -rf /root/selfcert

    # Generate a name and replace "NAME" in the server.json file
    name=$(openssl rand -hex 4)
    sed -i "s/NAME/$name/" /etc/tuic/server.json

    # Generate a password and replace "PASSWORD" in the server.json file
    password=$(openssl rand -hex 8)
    sed -i "s/PASSWORD/$password/" /etc/tuic/server.json

    # Generate uuid and replace "UUID" in the server.json file
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/UUID/$uuid/" /etc/tuic/server.json

    # Use a public DNS service to determine the public IP address
    public_ipv4=$(curl -s https://v4.ident.me)
    public_ipv6=$(curl -s https://v6.ident.me)

    # UFW optimization
    if sudo ufw status | grep -q "Status: active"; then

        # Disable UFW
        sudo ufw disable

        # Open config port
        sudo ufw allow "$user_port"/udp
        sleep 0.5

        # Enable & Reload
        echo "y" | sudo ufw enable
        sudo ufw reload

        echo 'UFW is Optimized.'

        sleep 0.5

    else

        echo "UFW in not active"

    fi

    # Enable and start the tuic service
    sudo systemctl enable --now TS

    # Construct and display the resulting URL
    result_url=" 
    ipv4 : tuic://$uuid:$password@$public_ipv4:$user_port?congestion_control=bbr&alpn=h3&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC
    ---------------------------------------------------------------
    ipv6 : tuic://$uuid:$password@[$public_ipv6]:$user_port?congestion_control=bbr&alpn=h3&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC"
    echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/tuic/config.txt # Red color for URL

    cat /etc/tuic/config.txt

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/tuic/config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/tuic/config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"

    echo "TUIC setup completed."

    echo -e "\e[31mPress Enter to Exit\e[0m"
    read
    clear
}

# Function to modify tuic configuration
modify_tuic_config() {
    tuic_check="/etc/tuic/server.json"

    if [ -e "$tuic_check" ]; then

        # Stop the tuic service
        sudo systemctl stop TS

        # Remove the existing configuration
        rm -rf /etc/tuic

        # Create a directory for tuic configuration and download the server.json file
        mkdir -p /etc/tuic && curl -Lo /etc/tuic/server.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/Tuic.json

        # Prompt the user to enter a port and replace "PORT" in the server.json file
        read -p "Please enter a port: " user_port
        sed -i "s/PORT/$user_port/" /etc/tuic/server.json

        # Get certificate
        mkdir /root/selfcert && cd /root/selfcert || exit

        openssl genrsa -out ca.key 2048

        openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=Apple Root CA" -out ca.crt

        openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=*.apple.com" -out server.csr

        openssl x509 -req -extfile <(printf "subjectAltName=DNS:apple.com,DNS:www.apple.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

        mv server.crt /etc/tuic/server.crt

        mv server.key /etc/tuic/server.key

        cd || exit

        rm -rf /root/selfcert

        # Generate a name and replace "NAME" in the server.json file
        name=$(openssl rand -hex 4)
        sed -i "s/NAME/$name/" /etc/tuic/server.json

        # Generate a password and replace "PASSWORD" in the server.json file
        password=$(openssl rand -hex 8)
        sed -i "s/PASSWORD/$password/" /etc/tuic/server.json

        # Generate uuid and replace "UUID" in the server.json file
        uuid=$(cat /proc/sys/kernel/random/uuid)
        sed -i "s/UUID/$uuid/" /etc/tuic/server.json

        # Use a public DNS service to determine the public IP address
        public_ipv4=$(curl -s https://v4.ident.me)
        public_ipv6=$(curl -s https://v6.ident.me)

        # UFW optimization
        if sudo ufw status | grep -q "Status: active"; then

            # Disable UFW
            sudo ufw disable

            # Open config port
            sudo ufw allow "$user_port"/udp
            sleep 0.5

            # Enable & Reload
            echo "y" | sudo ufw enable
            sudo ufw reload

            echo 'UFW is Optimized.'

            sleep 0.5

        else

            echo "UFW in not active"

        fi

        # Start the tuic service
        sudo systemctl start TS

        # Construct and display the resulting URL
        result_url=" 
        ipv4 : tuic://$uuid:$password@$public_ipv4:$user_port?congestion_control=bbr&alpn=h3&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC
        ---------------------------------------------------------------
        ipv6 : tuic://$uuid:$password@[$public_ipv6]:$user_port?congestion_control=bbr&alpn=h3&sni=www.apple.com&udp_relay_mode=native&allow_insecure=1#TUIC"
        echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/tuic/config.txt # Red color for URL

        cat /etc/tuic/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/tuic/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/tuic/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

        echo "TUIC configuration modified."

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear

    else

        whiptail --msgbox "TUIC is not installed yet." 10 30
        clear

    fi

}

# Function to uninstall tuic
uninstall_tuic() {
    # Stop the tuic service
    sudo systemctl stop TS

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/TS
    rm -rf /etc/tuic
    sudo rm -f /etc/systemd/system/TS.service

    whiptail --msgbox "TUIC uninstalled." 10 30
    clear

}

install_reality() {
    # Stop the RS service
    sudo systemctl stop RS

    # Remove RS binary, configuration, and service file
    sudo rm -f /usr/bin/RS
    rm -rf /etc/reality
    sudo rm -f /etc/systemd/system/RS.service

    # Download sing-box binary
    mkdir /root/singbox && cd /root/singbox || exit
    LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
    LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
    LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    wget "$LINK"
    tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/RS"
    cd && rm -rf singbox

    # Create a directory for RS configuration and download the Reality-gRPC.json file
    mkdir -p /etc/reality && curl -Lo /etc/reality/config.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/Reality-gRPC.json

    # Download the RS.service file
    curl -Lo /etc/systemd/system/RS.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/RS.service && systemctl daemon-reload

    # Prompt the user to enter a port and replace "PORT" in the config.json file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/reality/config.json

    # Prompt the user to enter a sni and replace "SNI" in the config.json file
    read -p "Please enter sni: " user_sni
    sed -i "s/SNI/$user_sni/" /etc/reality/config.json

    # Generate a name and replace "NAME" in the config.json file
    name=$(openssl rand -hex 4)
    sed -i "s/NAME/$name/" /etc/reality/config.json

    # Generate uuid and replace "UUID" in the config.json file
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/UUID/$uuid/" /etc/reality/config.json

    # Generate reality key-pair
    output=$(RS generate reality-keypair)

    private_key=$(echo "$output" | grep -oP 'PrivateKey: \K\S+')
    public_key=$(echo "$output" | grep -oP 'PublicKey: \K\S+')

    sed -i "s/PRIVATE-KEY/$private_key/" /etc/reality/config.json

    # Generate short id
    short_id=$(openssl rand -hex 8)
    sed -i "s/SHORT-ID/$short_id/" /etc/reality/config.json

    # Generate service name
    service_name=$(openssl rand -hex 4)
    sed -i "s/SERVICE-NAME/$service_name/" /etc/reality/config.json

    # Use a public DNS service to determine the public IP address
    public_ipv4=$(curl -s https://v4.ident.me)
    public_ipv6=$(curl -s https://v6.ident.me)

    # UFW optimization
    if sudo ufw status | grep -q "Status: active"; then

        # Disable UFW
        sudo ufw disable

        # Open config port
        sudo ufw allow "$user_port"
        sleep 0.5

        # Enable & Reload
        echo "y" | sudo ufw enable
        sudo ufw reload

        echo 'UFW is Optimized.'

        sleep 0.5

    else

        echo "UFW in not active"

    fi

    # Enable and start the sing-box service
    sudo systemctl enable --now RS

    # Construct and display the resulting URL
    result_url=" 
    ipv4 : vless://$uuid@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality
    ---------------------------------------------------------------
    ipv6 : vless://$uuid@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality"
    echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/reality/config.txt # Red color for URL

    cat /etc/reality/config.txt

    ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/reality/config.txt)
    ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/reality/config.txt)

    echo IPv4:
    qrencode -t ANSIUTF8 <<<"$ipv4qr"

    echo IPv6:
    qrencode -t ANSIUTF8 <<<"$ipv6qr"
    echo "Reality setup completed."

    echo -e "\e[31mPress Enter to Exit\e[0m"
    read
    clear
}

# Function to modify reality configuration
modify_reality_config() {
    reality_check="/etc/reality/config.json"

    if [ -e "$reality_check" ]; then

        # Stop the RS service
        sudo systemctl stop RS

        # Remove the existing configuration
        rm -rf /etc/reality

        # Create a directory for RS configuration and download the config.json file
        mkdir -p /etc/reality && curl -Lo /etc/reality/config.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/Reality-gRPC.json

        # Prompt the user to enter a port and replace "PORT" in the config.json file
        read -p "Please enter a port: " user_port
        sed -i "s/PORT/$user_port/" /etc/reality/config.json

        # Prompt the user to enter a sni and replace "SNI" in the config.json file
        read -p "Please enter sni: " user_sni
        sed -i "s/SNI/$user_sni/" /etc/reality/config.json

        # Generate a name and replace "NAME" in the config.json file
        name=$(openssl rand -hex 4)
        sed -i "s/NAME/$name/" /etc/reality/config.json

        # Generate uuid and replace "UUID" in the config.json file
        uuid=$(cat /proc/sys/kernel/random/uuid)
        sed -i "s/UUID/$uuid/" /etc/reality/config.json

        # Generate reality key-pair
        output=$(RS generate reality-keypair)

        private_key=$(echo "$output" | grep -oP 'PrivateKey: \K\S+')
        public_key=$(echo "$output" | grep -oP 'PublicKey: \K\S+')

        sed -i "s/PRIVATE-KEY/$private_key/" /etc/reality/config.json

        # Generate short id
        short_id=$(openssl rand -hex 8)
        sed -i "s/SHORT-ID/$short_id/" /etc/reality/config.json

        # Generate service name
        service_name=$(openssl rand -hex 4)
        sed -i "s/SERVICE-NAME/$service_name/" /etc/reality/config.json

        # Use a public DNS service to determine the public IP address
        public_ipv4=$(curl -s https://v4.ident.me)
        public_ipv6=$(curl -s https://v6.ident.me)

        # UFW optimization
        if sudo ufw status | grep -q "Status: active"; then

            # Disable UFW
            sudo ufw disable

            # Open config port
            sudo ufw allow "$user_port"
            sleep 0.5

            # Enable & Reload
            echo "y" | sudo ufw enable
            sudo ufw reload

            echo 'UFW is Optimized.'

            sleep 0.5

        else

            echo "UFW in not active"

        fi

        # Start the sing-box service
        sudo systemctl start RS

        # Construct and display the resulting URL
        result_url=" 
        ipv4 : vless://$uuid@$public_ipv4:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality
        ---------------------------------------------------------------
        ipv6 : vless://$uuid@[$public_ipv6]:$user_port?security=reality&sni=$user_sni&fp=firefox&pbk=$public_key&sid=$short_id&type=grpc&serviceName=$service_name&encryption=none#Reality"
        echo -e "Config URL: \e[91m$result_url\e[0m" >/etc/reality/config.txt # Red color for URL

        cat /etc/reality/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/reality/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/reality/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

        echo "Reality configuration modified."

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear

    else

        whiptail --msgbox "Reality is not installed yet." 10 30
        clear

    fi

}

# Function to uninstall reality
uninstall_reality() {
    # Stop the RS service
    sudo systemctl stop RS

    # Remove RS binary, configuration, and service file
    sudo rm -f /usr/bin/RS
    rm -rf /etc/reality
    sudo rm -f /etc/systemd/system/RS.service

    whiptail --msgbox "Reality uninstalled." 10 30
    clear

}

install_shadowtls() {
    # Stop the ST service
    sudo systemctl stop ST

    # Remove sing-box binary, configuration, and service file
    sudo rm -f /usr/bin/ST
    rm -rf /etc/shadowtls
    sudo rm -f /etc/systemd/system/ST.service

    # Download sing-box binary
    mkdir /root/singbox && cd /root/singbox || exit
    LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
    LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
    LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    wget "$LINK"
    tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/ST"
    cd && rm -rf singbox

    # Create a directory for shadowtls configuration and download the ShadowTLS.json file
    mkdir -p /etc/shadowtls && curl -Lo /etc/shadowtls/config.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/ShadowTLS.json

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

    # Generate shadowtls password and replace "STPASS" in the config files
    stpass=$(openssl rand -hex 16)
    sed -i "s/STPASS/$stpass/" /etc/shadowtls/config.json
    sed -i "s/STPASS/$stpass/" /etc/shadowtls/nekorayconfig.txt
    sed -i "s/STPASS/$stpass/" /etc/shadowtls/nekoboxconfig.txt

    # Generate shadowsocks password and replace "SSPASS" in the config files
    sspass=$(openssl rand -hex 16)
    sed -i "s/SSPASS/$sspass/" /etc/shadowtls/config.json
    sed -i "s/SSPASS/$sspass/" /etc/shadowtls/nekorayconfig.txt
    sed -i "s/SSPASS/$sspass/" /etc/shadowtls/nekoboxconfig.txt

    # Use a public DNS service to determine the public IP address and replace with IP in config.txt file
    public_ipv4=$(curl -s https://v4.ident.me)
    sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekorayconfig.txt
    sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekoboxconfig.txt

    # UFW optimization
    if sudo ufw status | grep -q "Status: active"; then

        # Disable UFW
        sudo ufw disable

        # Open config port
        sudo ufw allow "$user_port"
        sleep 0.5

        # Enable & Reload
        echo "y" | sudo ufw enable
        sudo ufw reload

        echo 'UFW is Optimized.'

        sleep 0.5

    else

        echo "UFW in not active"

    fi

    # Enable and start the ST service
    sudo systemctl enable --now ST

    # Display the resulting config

    echo "ShadowTLS config for Nekoray : "

    echo

    cat /etc/shadowtls/nekorayconfig.txt

    echo

    echo "ShadowTLS config for Nekobox : "

    echo

    cat /etc/shadowtls/nekoboxconfig.txt

    echo

    echo "ShadowTLS setup completed."

    echo -e "\e[31mPress Enter to Exit\e[0m"
    read
    clear
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
        mkdir -p /etc/shadowtls && curl -Lo /etc/shadowtls/config.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/ShadowTLS.json

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

        # Generate shadowtls password and replace "STPASS" in the config files
        stpass=$(openssl rand -hex 16)
        sed -i "s/STPASS/$stpass/" /etc/shadowtls/config.json
        sed -i "s/STPASS/$stpass/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/STPASS/$stpass/" /etc/shadowtls/nekoboxconfig.txt

        # Generate shadowsocks password and replace "SSPASS" in the config files
        sspass=$(openssl rand -hex 16)
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/config.json
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/SSPASS/$sspass/" /etc/shadowtls/nekoboxconfig.txt

        # Use a public DNS service to determine the public IP address and replace with IP in config.txt file
        public_ipv4=$(curl -s https://v4.ident.me)
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekorayconfig.txt
        sed -i "s/IP/$public_ipv4/" /etc/shadowtls/nekoboxconfig.txt

        # UFW optimization
        if sudo ufw status | grep -q "Status: active"; then

            # Disable UFW
            sudo ufw disable

            # Open config port
            sudo ufw allow "$user_port"
            sleep 0.5

            # Enable & Reload
            echo "y" | sudo ufw enable
            sudo ufw reload

            echo 'UFW is Optimized.'

            sleep 0.5

        else

            echo "UFW in not active"

        fi

        # start the ST service
        sudo systemctl start ST

        # Display the resulting config

        echo "ShadowTLS config for Nekoray : "

        echo

        cat /etc/shadowtls/nekorayconfig.txt

        echo

        echo "ShadowTLS config for Nekobox : "

        echo

        cat /etc/shadowtls/nekoboxconfig.txt

        echo

        echo "ShadowTLS configuration modified."

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear

    else

        whiptail --msgbox "ShadowTLS is not installed yet." 10 30
        clear

    fi

}

# Function to uninstall shadowtls
uninstall_shadowtls() {
    # Stop the ST service
    sudo systemctl stop ST

    # Remove sing-box binary, configuration, and service file
    sudo rm -f /usr/bin/ST
    rm -rf /etc/shadowtls
    sudo rm -f /etc/systemd/system/ST.service

    whiptail --msgbox "ShadowTLS uninstalled." 10 30
    clear

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

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear

    else

        whiptail --msgbox "Hysteria2 is not installed yet." 10 30
        clear

    fi

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

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear

    else

        whiptail --msgbox "TUIC is not installed yet." 10 30
        clear

    fi

}

# Function to show reality config
show_reality_config() {
    reality_check="/etc/reality/config.txt"

    if [ -e "$reality_check" ]; then

        cat /etc/reality/config.txt

        ipv4qr=$(grep -oP 'ipv4 : \K\S+' /etc/reality/config.txt)
        ipv6qr=$(grep -oP 'ipv6 : \K\S+' /etc/reality/config.txt)

        echo IPv4:
        qrencode -t ANSIUTF8 <<<"$ipv4qr"

        echo IPv6:
        qrencode -t ANSIUTF8 <<<"$ipv6qr"

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear

    else

        whiptail --msgbox "Reality is not installed yet." 10 30
        clear

    fi

}

# Function to show shadowtls config
show_shadowtls_config() {
    shadowtls_check="/etc/shadowtls/nekorayconfig.txt"

    if [ -e "$shadowtls_check" ]; then

        echo "ShadowTLS config for Nekoray : "

        echo

        cat /etc/shadowtls/nekorayconfig.txt

        echo

        echo "ShadowTLS config for Nekobox : "

        echo

        cat /etc/shadowtls/nekoboxconfig.txt

        echo

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear

    else

        whiptail --msgbox "ShadowTLS is not installed yet." 10 30
        clear

    fi

}

# Function to show warp config
show_warp_config() {
    warp_conf_check="/etc/sbw/proxy.json"

    if [ -e "$warp_conf_check" ]; then

        cat /etc/sbw/proxy.json | jq

        echo -e "\e[31mPress Enter to Exit\e[0m"
        read
        clear

    else

        whiptail --msgbox "WARP is not installed yet." 10 30
        clear

    fi

}

# Generate WARP+ Key
warp_key_gen() {

    curl -fsSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/WARP%2B-sing-box-config-generator/key-generator.py -o key-generator.py
    python3 key-generator.py

    rm -f key-generator.py

    clear
}

# Function to install warp
install_warp() {
    # WARP+ installation
    warp_check="/etc/systemd/system/SBW.service"

    if [ -e "$warp_check" ]; then

        whiptail --msgbox "WARP is running." 10 30
        clear

    else

        # Download sing-box core for WARP+ wireguard config
        mkdir /root/singbox && cd /root/singbox || exit
        LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
        LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
        LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        wget "$LINK"
        tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/SBW"
        cd && rm -rf singbox

        # Download SBW service file
        curl -Lo /etc/systemd/system/SBW.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/SBW.service && systemctl daemon-reload

        # Generate WARP+ wireguard config file for sing-box
        mkdir /etc/sbw && cd /etc/sbw || exit

        wget https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/WARP%2B-sing-box-config-generator/main.sh
        wget https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/WARP%2B-sing-box-config-generator/warp-api
        wget https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/WARP%2B-sing-box-config-generator/warp-go

        chmod +x main.sh
        ./main.sh

        rm -f warp-go warp-api main.sh warp.conf

        cd || exit

        # Start WARP+ sing-box proxy
        systemctl enable --now SBW

        whiptail --msgbox "WARP installed successfuly" 10 30
        clear

    fi

}

# Function to uninstall warp
uninstall_warp() {
    # Stop the SBW service
    sudo systemctl stop SBW

    # Remove sing-box binary, configuration, and service file
    sudo rm -f /usr/bin/SBW
    rm -rf /etc/sbw
    sudo rm -f /etc/systemd/system/SBW.service

    file1="/etc/reality/config.json"

    if [ -e "$file1" ]; then

        if jq -e '.outbounds[0].type == "socks"' "$file1" &>/dev/null; then
            # Set the new JSON object for outbounds (switch to direct)
            new_json='{
            "tag": "direct",
            "type": "direct"
        }'

            jq '.outbounds = ['"$new_json"']' "$file1" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file1"

            systemctl restart RS

            echo "WARP is disabled on Reality"
        else

            echo
        fi

    else
        echo
    fi

    file2="/etc/shadowtls/config.json"

    if [ -e "$file2" ]; then

        if jq -e '.outbounds[0].type == "socks"' "$file2" &>/dev/null; then
            # Set the new JSON object for outbounds (switch to direct)
            new_json='{
            "tag": "direct",
            "type": "direct"
        }'

            jq '.outbounds = ['"$new_json"']' "$file2" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file2"

            systemctl restart ST

            echo "WARP is disabled on ShadowTLS"
        else

            echo
        fi

    else
        echo
    fi

    file3="/etc/tuic/server.json"

    if [ -e "$file3" ]; then

        if jq -e '.outbounds[0].type == "socks"' "$file3" &>/dev/null; then
            # Set the new JSON object for outbounds (switch to direct)
            new_json='{
            "tag": "direct",
            "type": "direct"
        }'

            jq '.outbounds = ['"$new_json"']' "$file3" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file3"

            systemctl restart TS

            echo "WARP is disabled on TUIC"
        else

            echo
        fi

    else
        echo
    fi

    file4="/etc/hysteria2/server.json"

    if [ -e "$file4" ]; then

        if jq -e '.outbounds[0].type == "socks"' "$file4" &>/dev/null; then
            # Set the new JSON object for outbounds (switch to direct)
            new_json='{
            "tag": "direct",
            "type": "direct"
        }'

            jq '.outbounds = ['"$new_json"']' "$file4" >/tmp/tmp_config.json
            mv /tmp/tmp_config.json "$file4"

            systemctl restart SH

            echo "WARP is disabled on Hysteria2"
        else

            echo
        fi

    else
        echo
    fi

    whiptail --msgbox "WARP uninstalled." 10 30
    clear

}

# Function to update sing-box core
update_sing-box_core() {
    rlt_core_check="/usr/bin/RS"

    if [ -e "$rlt_core_check" ]; then

        systemctl stop RS

        rm /usr/bin/RS

        # Download sing-box binary
        mkdir /root/singbox && cd /root/singbox || exit
        LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
        LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
        LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        wget "$LINK"
        tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/RS"
        cd && rm -rf singbox

        systemctl start RS

        echo "Reality sing-box core has been updated"

    else

        echo "Reality is not installed yet."

    fi

    st_core_check="/usr/bin/ST"

    if [ -e "$st_core_check" ]; then

        systemctl stop ST

        rm /usr/bin/ST

        # Download sing-box binary
        mkdir /root/singbox && cd /root/singbox || exit
        LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
        LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
        LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        wget "$LINK"
        tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/ST"
        cd && rm -rf singbox

        systemctl start ST

        echo "ShadowTLS sing-box core has been updated"

    else

        echo "ShadowTLS is not installed yet."

    fi

    ts_core_check="/usr/bin/TS"

    if [ -e "$ts_core_check" ]; then

        systemctl stop TS

        rm /usr/bin/TS

        # Download sing-box binary
        mkdir /root/singbox && cd /root/singbox || exit
        LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
        LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
        LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        wget "$LINK"
        tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/TS"
        cd && rm -rf singbox

        systemctl start TS

        echo "TUIC sing-box core has been updated"

    else

        echo "TUIC is not installed yet."

    fi

    wg_core_check="/usr/bin/SBW"

    if [ -e "$wg_core_check" ]; then

        systemctl stop SBW

        rm /usr/bin/SBW

        # Download sing-box binary
        mkdir /root/singbox && cd /root/singbox || exit
        LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
        LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
        LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        wget "$LINK"
        tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/SBW"
        cd && rm -rf singbox

        systemctl start SBW

        echo "WARP sing-box core has been updated"

    else

        echo "WARP is not installed yet."

    fi

    sh_core_check="/usr/bin/SH"

    if [ -e "$sh_core_check" ]; then

        systemctl stop SH

        rm /usr/bin/SH

        # Download sing-box binary
        mkdir /root/singbox && cd /root/singbox || exit
        LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
        LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
        LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        wget "$LINK"
        tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/SH"
        cd && rm -rf singbox

        systemctl start SH

        echo "Hysteria2 sing-box core has been updated"

    else

        echo "Hysteria2 is not installed yet."

    fi

    whiptail --msgbox "Sing-Box Cores Has Been Updated" 10 30
    clear

}

# Function to disable warp on reality
toggle_warp_reality() {
    file="/etc/reality/config.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then

        if [ -e "$warp" ]; then

            systemctl stop RS

            if jq -e '.outbounds[0].type == "socks"' "$file" &>/dev/null; then
                # Set the new JSON object for outbounds (switch to direct)
                new_json='{
            "tag": "direct",
            "type": "direct"
        }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"

                systemctl start RS

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                # Set the new JSON object for outbounds (switch to socks)
                new_json='{
            "type": "socks",
            "tag": "socks-out",
            "server": "127.0.0.1",
            "server_port": 2000,
            "version": "5"
        }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"

                systemctl start RS

                whiptail --msgboxho "WARP is enabled now" 10 30
                clear
            fi

        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear

        fi

    else
        whiptail --msgbox "Reality is not installed yet." 10 30
        clear
    fi

}

# Function to disable warp on shadowtls
toggle_warp_shadowtls() {
    file="/etc/shadowtls/config.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then

        if [ -e "$warp" ]; then

            systemctl stop ST

            if jq -e '.outbounds[0].type == "socks"' "$file" &>/dev/null; then
                # Set the new JSON object for outbounds (switch to direct)
                new_json='{
            "tag": "direct",
            "type": "direct"
        }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"

                systemctl start ST

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                # Set the new JSON object for outbounds (switch to socks)
                new_json='{
            "type": "socks",
            "tag": "socks-out",
            "server": "127.0.0.1",
            "server_port": 2000,
            "version": "5"
        }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"

                systemctl start ST

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi

        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear

        fi

    else
        whiptail --msgbox "ShadowTLS is not installed yet." 10 30
        clear
    fi

}

# Function to disable warp on tuic
toggle_warp_tuic() {
    file="/etc/tuic/server.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then

        if [ -e "$warp" ]; then

            systemctl stop TS

            if jq -e '.outbounds[0].type == "socks"' "$file" &>/dev/null; then
                # Set the new JSON object for outbounds (switch to direct)
                new_json='{
            "tag": "direct",
            "type": "direct"
        }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"

                systemctl start TS

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                # Set the new JSON object for outbounds (switch to socks)
                new_json='{
            "type": "socks",
            "tag": "socks-out",
            "server": "127.0.0.1",
            "server_port": 2000,
            "version": "5"
        }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"

                systemctl start TS

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi

        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear

        fi

    else
        whiptail --msgbox "TUIC is not installed yet." 10 30
        clear
    fi

}

# Function to disable warp on hysteria2
toggle_warp_hysteria() {
    file="/etc/hysteria2/server.json"
    warp="/etc/sbw/proxy.json"

    if [ -e "$file" ]; then

        if [ -e "$warp" ]; then

            systemctl stop SH

            if jq -e '.outbounds[0].type == "socks"' "$file" &>/dev/null; then
                # Set the new JSON object for outbounds (switch to direct)
                new_json='{
            "tag": "direct",
            "type": "direct"
        }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"

                systemctl start SH

                whiptail --msgbox "WARP is disabled now" 10 30
                clear
            else
                # Set the new JSON object for outbounds (switch to socks)
                new_json='{
            "type": "socks",
            "tag": "socks-out",
            "server": "127.0.0.1",
            "server_port": 2000,
            "version": "5"
        }'

                jq '.outbounds = ['"$new_json"']' "$file" >/tmp/tmp_config.json
                mv /tmp/tmp_config.json "$file"

                systemctl start SH

                whiptail --msgbox "WARP is enabled now" 10 30
                clear
            fi

        else
            whiptail --msgbox "WARP is not installed yet" 10 30
            clear

        fi

    else
        whiptail --msgbox "Hysteria2 is not installed yet." 10 30
        clear
    fi

}

# Function to optimize server
optimize_server() {

    bash -c "$(curl -fsSL https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box_Config_Installer/server-optimizer.sh)"
    clear

}

check_system_info() {
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

    for ex in "${EXCLUDE[@]}"; do [[ ! $(tr 'A-Z' 'a-z' <<<"$SYS") =~ $ex ]]; done &&
        [[ "$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)" -lt "${MAJOR[int]}" ]] && error " $(text_eval 6) "

    KERNEL=$(uname -r)
    ARCHITECTURE=$(uname -m)

}

get_cpu_usage() {
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
    cpu_usage_percentage=$(awk "BEGIN {printf \"%.2f\", 100 * (1 - $delta_idle / $delta_total)}")

}

get_ram_usage() {
    memory_info=$(free | grep Mem)
    total_memory=$(echo $memory_info | awk '{print $2}')
    used_memory=$(echo $memory_info | awk '{print $3}')
    memory_usage=$(awk "BEGIN {printf \"%.2f\", $used_memory / $total_memory * 100}")

}

get_storage_usage() {
    storage_info=$(df / | awk 'NR==2{print $3,$2}')
    used_storage=$(echo $storage_info | awk '{print $1}')
    total_storage=$(echo $storage_info | awk '{print $2}')
    storage_usage=$(awk "BEGIN {printf \"%.2f\", $used_storage / $total_storage * 100}")

}

check_system_ip() {
    IP4=$(wget -4 -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 http://ip-api.com/json/) &&
        WAN4=$(expr "$IP4" : '.*query\":[ ]*\"\([^"]*\).*') &&
        COUNTRY4=$(expr "$IP4" : '.*country\":[ ]*\"\([^"]*\).*') &&
        ISP4=$(expr "$IP4" : '.*isp\":[ ]*\"\([^"]*\).*') &&
        [[ "$L" = C && -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")

    IP6=$(wget -6 -qO- --no-check-certificate --user-agent=Mozilla --tries=2 --timeout=1 https://api.ip.sb/geoip) &&
        WAN6=$(expr "$IP6" : '.*ip\":[ ]*\"\([^"]*\).*') &&
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
