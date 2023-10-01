#!/bin/bash

# Function to install Hysteria
install_hysteria() {
    apt update && apt install -y qrencode jq openssl

    # Stop the Hysteria2 service
    sudo systemctl stop hysteria2

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/hysteria2
    rm -rf /etc/hysteria2
    sudo rm -f /etc/systemd/system/hysteria2.service

    # Download Hysteria binary and make it executable
    curl -Lo /root/hysteria2 https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 && chmod +x /root/hysteria2 && mv -f /root/hysteria2 /usr/bin

    # Create a directory for Hysteria configuration and download the server.yaml file
    mkdir -p /etc/hysteria2 && curl -Lo /etc/hysteria2/server.yaml https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/server-auto-warp.yaml

    # Download the hysteria2.service file
    curl -Lo /etc/systemd/system/hysteria2.service https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Hysteria/2/hysteria2.service && systemctl daemon-reload

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

    # Prompt the user to enter a port and replace "PORT" in the server.yaml file
    read -p "Please enter a port: " user_port
    sed -i "s/PORT/$user_port/" /etc/hysteria2/server.yaml

    # Generate a password and replace "PASSWORD" in the server.yaml file
    password=$(openssl rand -hex 8)
    sed -i "s/PASSWORD/$password/" /etc/hysteria2/server.yaml

    # Use a public DNS service to determine the public IP address
    public_ipv4=$(curl -s https://v4.ident.me)
    public_ipv6=$(curl -s https://v6.ident.me)

    # WARP+ installation
    warp_check="/etc/systemd/system/SBW.service"

    if [ -e "$warp_check" ]; then

        echo "WARP is running."

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

    fi

    # UFW optimization
    if sudo ufw status | grep -q "Status: active"; then

        # Disable UFW
        sudo ufw disable

        # Open config port
        sudo ufw allow "$user_port"/udp
        sleep 0.5

        # Enable & Reload
        sudo ufw enable
        sudo ufw reload

        echo 'UFW is Optimized.'

        sleep 0.5

    else

        echo "UFW in not active"

    fi

    # Enable and start the Hysteria2 service
    sudo systemctl enable --now hysteria2

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

        # Prompt the user to enter a port and replace "PORT" in the server.yaml file
        read -p "Please enter a port: " user_port
        sed -i "s/PORT/$user_port/" /etc/hysteria2/server.yaml

        # Generate a password and replace "PASSWORD" in the server.yaml file
        password=$(openssl rand -hex 8)
        sed -i "s/PASSWORD/$password/" /etc/hysteria2/server.yaml

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
            sudo ufw enable
            sudo ufw reload

            echo 'UFW is Optimized.'

            sleep 0.5

        else

            echo "UFW in not active"

        fi

        # Start the Hysteria2 service
        sudo systemctl start hysteria2

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
    apt update && apt install -y qrencode jq openssl

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
    mkdir -p /etc/tuic && curl -Lo /etc/tuic/server.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/tuic%2Bwarp.json

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

    # Generate a password and replace "PASSWORD" in the server.json file
    password=$(openssl rand -hex 8)
    sed -i "s/PASSWORD/$password/" /etc/tuic/server.json

    # Generate uuid and replace "UUID" in the server.json file
    uuid=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/UUID/$uuid/" /etc/tuic/server.json

    # Use a public DNS service to determine the public IP address
    public_ipv4=$(curl -s https://v4.ident.me)
    public_ipv6=$(curl -s https://v6.ident.me)

    # WARP+ installation
    warp_check="/etc/systemd/system/SBW.service"

    if [ -e "$warp_check" ]; then

        echo "WARP is running."

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

    fi

    # UFW optimization
    if sudo ufw status | grep -q "Status: active"; then

        # Disable UFW
        sudo ufw disable

        # Open config port
        sudo ufw allow "$user_port"/udp
        sleep 0.5

        # Enable & Reload
        sudo ufw enable
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

    exit 0 # Exit the script immediately with a successful status
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
        mkdir -p /etc/tuic && curl -Lo /etc/tuic/server.json https://raw.githubusercontent.com/TheyCallMeSecond/config-examples/main/Sing-Box/Server/tuic%2Bwarp.json

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
            sudo ufw enable
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

    else

        echo "TUIC is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to uninstall tuic
uninstall_tuic() {
    # Stop the tuic service
    sudo systemctl stop TS

    # Remove Hysteria binary, configuration, and service file
    sudo rm -f /usr/bin/TS
    rm -rf /etc/tuic
    sudo rm -f /etc/systemd/system/TS.service

    echo "TUIC uninstalled."

    exit 0 # Exit the script immediately with a successful status
}

install_reality() {
    apt update && apt install -y qrencode jq openssl

    # Stop the sing-box service
    sudo systemctl stop sing-box

    # Remove sing-box binary, configuration, and service file
    sudo rm -f /usr/bin/sing-box
    rm -rf /etc/sing-box
    sudo rm -f /etc/systemd/system/sing-box.service

    # Download sing-box binary
    mkdir /root/singbox && cd /root/singbox || exit
    LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
    LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
    LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    wget "$LINK"
    tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
    cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/sing-box"
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
    warp_check="/etc/systemd/system/SBW.service"

    if [ -e "$warp_check" ]; then

        echo "WARP is running."

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

    fi

    # UFW optimization
    if sudo ufw status | grep -q "Status: active"; then

        # Disable UFW
        sudo ufw disable

        # Open config port
        sudo ufw allow "$user_port"
        sleep 0.5

        # Enable & Reload
        sudo ufw enable
        sudo ufw reload

        echo 'UFW is Optimized.'

        sleep 0.5

    else

        echo "UFW in not active"

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

        # UFW optimization
        if sudo ufw status | grep -q "Status: active"; then

            # Disable UFW
            sudo ufw disable

            # Open config port
            sudo ufw allow "$user_port"
            sleep 0.5

            # Enable & Reload
            sudo ufw enable
            sudo ufw reload

            echo 'UFW is Optimized.'

            sleep 0.5

        else

            echo "UFW in not active"

        fi

        # Start the sing-box service
        sudo systemctl start sing-box

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
    apt update && apt install -y jq openssl

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

    # WARP+ installation
    warp_check="/etc/systemd/system/SBW.service"

    if [ -e "$warp_check" ]; then

        echo "WARP is running."

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

    fi

    # UFW optimization
    if sudo ufw status | grep -q "Status: active"; then

        # Disable UFW
        sudo ufw disable

        # Open config port
        sudo ufw allow "$user_port"
        sleep 0.5

        # Enable & Reload
        sudo ufw enable
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
            sudo ufw enable
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

        echo

        cat /etc/shadowtls/nekorayconfig.txt

        echo

        echo "ShadowTLS config for Nekobox : "

        echo

        cat /etc/shadowtls/nekoboxconfig.txt

        echo

    else

        echo "ShadowTLS is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to show warp config
show_warp_config() {
    warp_conf_check="/etc/sbw/proxy.json"

    if [ -e "$warp_conf_check" ]; then

        cat /etc/sbw/proxy.json | jq

    else

        echo "WARP is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to install warp
install_warp() {
    # WARP+ installation
    warp_check="/etc/systemd/system/SBW.service"

    if [ -e "$warp_check" ]; then

        echo "WARP is running."

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

        echo "WARP installed successfuly"

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to uninstall warp
uninstall_warp() {
    # Stop the SBW service
    sudo systemctl stop SBW

    # Remove sing-box binary, configuration, and service file
    sudo rm -f /usr/bin/SBW
    rm -rf /etc/sbw
    sudo rm -f /etc/systemd/system/SBW.service

    echo "WARP uninstalled."

    exit 0 # Exit the script immediately with a successful status
}

# Function to update sing-box core
update_sing-box_core() {
    rlt_core_check="/usr/bin/sing-box"

    if [ -e "$rlt_core_check" ]; then

        systemctl stop sing-box

        rm /usr/bin/sing-box

        # Download sing-box binary
        mkdir /root/singbox && cd /root/singbox || exit
        LATEST_URL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/SagerNet/sing-box/releases/latest)
        LATEST_VERSION="$(echo $LATEST_URL | grep -o -E '/.?[0-9|\.]+$' | grep -o -E '[0-9|\.]+')"
        LINK="https://github.com/SagerNet/sing-box/releases/download/v${LATEST_VERSION}/sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        wget "$LINK"
        tar -xf "sing-box-${LATEST_VERSION}-linux-amd64.tar.gz"
        cp "sing-box-${LATEST_VERSION}-linux-amd64/sing-box" "/usr/bin/sing-box"
        cd && rm -rf singbox

        systemctl start sing-box

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

    exit 0 # Exit the script immediately with status
}

# Function to disable warp on reality
disable_warp_reality() {
    reality_check="/etc/sing-box/config.json"

    if [ -e "$reality_check" ]; then
        file="/etc/sing-box/config.json"
        threshold=98

        line_count=$(wc -l <"$file")

        if [ "$line_count" -gt "$threshold" ]; then
            systemctl stop sing-box

            # Set the new JSON object
            new_json='{
            "tag": "direct",
            "type": "direct"
        }'

            # Change outbound from socks to direct
            awk -v new_json="$new_json" 'NR<83 || NR>95 {print} NR==83 {print new_json}' /etc/sing-box/config.json >/etc/sing-box/config.tmp
            mv /etc/sing-box/config.tmp /etc/sing-box/config.json

            systemctl start sing-box

            echo "WARP is disabled now"
        else
            echo "WARP is already disable"
        fi

    else

        echo "Reality is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to disable warp on shadowtls
disable_warp_shadowtls() {
    shadowtls_check="/etc/sing-box/config.json"

    if [ -e "$shadowtls_check" ]; then
        file="/etc/shadowtls/config.json"
        threshold=56

        line_count=$(wc -l <"$file")

        if [ "$line_count" -gt "$threshold" ]; then
            systemctl stop ST

            # Set the new JSON object
            new_json='{
            "tag": "direct",
            "type": "direct"
        }
        ]'

            # Change outbound from socks to direct
            awk -v new_json="$new_json" 'NR<41 || NR>56 {print} NR==41 {print new_json}' /etc/shadowtls/config.json >/etc/shadowtls/config.tmp
            mv /etc/shadowtls/config.tmp /etc/shadowtls/config.json

            systemctl start ST

            echo "WARP is disabled now"
        else
            echo "WARP is already disable"
        fi

    else

        echo "ShadowTLS is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to disable warp on tuic
disable_warp_tuic() {
    tuic_check="/etc/tuic/server.json"

    if [ -e "$tuic_check" ]; then
        file="/etc/tuic/server.json"
        threshold=42

        line_count=$(wc -l <"$file")

        if [ "$line_count" -gt "$threshold" ]; then
            systemctl stop TS

            # Set the new JSON object
            new_json='{
            "tag": "direct",
            "type": "direct"
        }'

            # Change outbound from socks to direct
            awk -v new_json="$new_json" 'NR<35 || NR>41 {print} NR==35 {print new_json}' /etc/tuic/server.json >/etc/tuic/server.tmp
            mv /etc/tuic/server.tmp /etc/tuic/server.json

            systemctl start TS

            echo "WARP is disabled now"
        else
            echo "WARP is already disable"
        fi

    else

        echo "TUIC is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to disable warp on hysteria2
disable_warp_hysteria() {
    hysteria_check="/etc/hysteria2/server.yaml"

    if [ -e "$hysteria_check" ]; then
        file="/etc/hysteria2/server.yaml"
        threshold=50

        line_count=$(wc -l <"$file")

        if [ "$line_count" -gt "$threshold" ]; then
            systemctl stop hysteria2

            # Set the new yaml object
            new_yaml='  - name: direct
                          type: direct'

            # Change outbound from socks to direct
            awk -v new_yaml="$new_yaml" 'NR<41 || NR>44 {print} NR==41 {print new_yaml}' /etc/hysteria2/server.yaml >/etc/hysteria2/server.tmp
            mv /etc/hysteria2/server.tmp /etc/hysteria2/server.yaml

            systemctl start hysteria2

            echo "WARP is disabled now"
        else
            echo "WARP is already disable"
        fi

    else

        echo "Hysteria is not installed yet."

    fi

    exit 0 # Exit the script immediately with a successful status
}

# Function to optimize server
optimize_server() {
    # Green, Yellow & Red Messages.
    green_msg() {
        tput setaf 2
        echo "[*] ----- $1"
        tput sgr0
    }

    yellow_msg() {
        tput setaf 3
        echo "[*] ----- $1"
        tput sgr0
    }

    red_msg() {
        tput setaf 1
        echo "[*] ----- $1"
        tput sgr0
    }

    # Declare Paths & Settings.
    SYS_PATH="/etc/sysctl.conf"
    LIM_PATH="/etc/security/limits.conf"
    PROF_PATH="/etc/profile"
    SSH_PATH="/etc/ssh/sshd_config"

    # Root
    check_if_running_as_root() {
        # If you want to run as another user, please modify $EUID to be owned by this user
        if [[ "$EUID" -ne '0' ]]; then
            echo
            red_msg 'Error: You must run this script as root!'
            echo
            sleep 0.5
            exit 1
        fi
    }

    # Check Root
    check_if_running_as_root
    sleep 0.5

    # Ask Reboot
    ask_reboot() {
        yellow_msg 'Reboot now? (Recommended) (y/n)'
        echo
        while true; do
            read choice
            echo
            if [[ "$choice" == 'y' || "$choice" == 'Y' ]]; then
                sleep 0.5
                reboot
                exit 0
            fi
            if [[ "$choice" == 'n' || "$choice" == 'N' ]]; then
                break
            fi
        done
    }

    # Update & Upgrade & Remove & Clean
    complete_update() {
        echo
        yellow_msg 'Updating the System.'
        echo
        sleep 0.5

        sudo apt update
        sudo apt -y upgrade
        sudo apt -y dist-upgrade
        sudo apt -y autoremove
        sleep 0.5

        # Again :D
        sudo apt -y autoclean
        sudo apt -y clean
        sudo apt update
        sudo apt -y upgrade
        sudo apt -y dist-upgrade
        sudo apt -y autoremove

        echo
        green_msg 'System Updated Successfully.'
        echo
        sleep 0.5
    }

    ## Install useful packages
    installations() {
        echo
        yellow_msg 'Installing Useful Packages.'
        echo
        sleep 0.5

        # Networking packages
        sudo apt -y install apt-transport-https iptables iptables-persistent nftables

        # System utilities
        sudo apt -y install apt-utils bash-completion busybox ca-certificates cron curl gnupg2 locales lsb-release nano preload screen software-properties-common ufw unzip vim wget xxd zip

        # Programming and development tools
        sudo apt -y install autoconf automake bash-completion build-essential git libtool make pkg-config python3 python3-pip

        # Additional libraries and dependencies
        sudo apt -y install bc binutils binutils-common binutils-x86-64-linux-gnu ubuntu-keyring haveged jq libsodium-dev libsqlite3-dev libssl-dev packagekit qrencode socat

        # Miscellaneous
        sudo apt -y install dialog htop net-tools

        echo
        green_msg 'Useful Packages Installed Succesfully.'
        echo
        sleep 0.5
    }

    # Enable packages at server boot
    enable_packages() {
        sudo systemctl enable cron haveged nftables preload
        echo
        green_msg 'Packages Enabled Succesfully.'
        echo
        sleep 0.5
    }

    ## SYSCTL Optimization
    sysctl_optimizations() {
        # Make a backup of the original sysctl.conf file
        cp $SYS_PATH /etc/sysctl.conf.bak

        echo
        yellow_msg 'Default sysctl.conf file Saved. Directory: /etc/sysctl.conf.bak'
        echo
        sleep 1

        echo
        yellow_msg 'Optimizing the Network.'
        echo
        sleep 0.5

        # Replace the new sysctl.conf file.
        wget "https://raw.githubusercontent.com/TheyCallMeSecond/Linux-Optimizer/main/files/sysctl.conf" -q -O $SYS_PATH

        sysctl -p
        echo

        green_msg 'Network is Optimized.'
        echo
        sleep 0.5
    }

    # Remove old SSH config to prevent duplicates.
    remove_old_ssh_conf() {
        # Make a backup of the original sshd_config file
        cp $SSH_PATH /etc/ssh/sshd_config.bak

        echo
        yellow_msg 'Default SSH Config file Saved. Directory: /etc/ssh/sshd_config.bak'
        echo
        sleep 1

        # Disable DNS lookups for connecting clients
        sed -i 's/#UseDNS yes/UseDNS no/' $SSH_PATH

        # Enable compression for SSH connections
        sed -i 's/#Compression no/Compression yes/' $SSH_PATH

        # Remove less efficient encryption ciphers
        sed -i 's/Ciphers .*/Ciphers aes256-ctr,chacha20-poly1305@openssh.com/' $SSH_PATH

        # Remove these lines
        sed -i '/MaxAuthTries/d' $SSH_PATH
        sed -i '/MaxSessions/d' $SSH_PATH
        sed -i '/TCPKeepAlive/d' $SSH_PATH
        sed -i '/ClientAliveInterval/d' $SSH_PATH
        sed -i '/ClientAliveCountMax/d' $SSH_PATH
        sed -i '/AllowAgentForwarding/d' $SSH_PATH
        sed -i '/AllowTcpForwarding/d' $SSH_PATH
        sed -i '/GatewayPorts/d' $SSH_PATH
        sed -i '/PermitTunnel/d' $SSH_PATH
        sed -i '/X11Forwarding/d' $SSH_PATH
    }

    ## Update SSH config
    update_sshd_conf() {
        echo
        yellow_msg 'Optimizing SSH.'
        echo
        sleep 0.5

        # Enable TCP keep-alive messages
        echo "TCPKeepAlive yes" | tee -a $SSH_PATH

        # Configure client keep-alive messages
        echo "ClientAliveInterval 3000" | tee -a $SSH_PATH
        echo "ClientAliveCountMax 100" | tee -a $SSH_PATH

        # Allow agent forwarding
        echo "AllowAgentForwarding yes" | tee -a $SSH_PATH

        # Allow TCP forwarding
        echo "AllowTcpForwarding yes" | tee -a $SSH_PATH

        # Enable gateway ports
        echo "GatewayPorts yes" | tee -a $SSH_PATH

        # Enable tunneling
        echo "PermitTunnel yes" | tee -a $SSH_PATH

        # Enable X11 graphical interface forwarding
        echo "X11Forwarding yes" | tee -a $SSH_PATH

        # Restart the SSH service to apply the changes
        service ssh restart

        echo
        green_msg 'SSH is Optimized.'
        echo
        sleep 0.5
    }

    # System Limits Optimizations
    limits_optimizations() {
        echo
        yellow_msg 'Optimizing System Limits.'
        echo
        sleep 0.5

        # Clear old ulimits
        sed -i '/ulimit -c/d' $PROF_PATH
        sed -i '/ulimit -d/d' $PROF_PATH
        sed -i '/ulimit -f/d' $PROF_PATH
        sed -i '/ulimit -i/d' $PROF_PATH
        sed -i '/ulimit -n/d' $PROF_PATH
        sed -i '/ulimit -q/d' $PROF_PATH
        sed -i '/ulimit -u/d' $PROF_PATH
        sed -i '/ulimit -v/d' $PROF_PATH
        sed -i '/ulimit -x/d' $PROF_PATH
        sed -i '/ulimit -s/d' $PROF_PATH
        sed -i '/ulimit -l/d' $PROF_PATH

        # Add new ulimits
        # The maximum size of core files created.
        echo "ulimit -c unlimited" | tee -a $PROF_PATH

        # The maximum size of a process's data segment
        echo "ulimit -d unlimited" | tee -a $PROF_PATH

        # The maximum size of files created by the shell (default option)
        echo "ulimit -f unlimited" | tee -a $PROF_PATH

        # The maximum number of pending signals
        echo "ulimit -i unlimited" | tee -a $PROF_PATH

        # The maximum number of open file descriptors
        echo "ulimit -n 999999" | tee -a $PROF_PATH

        # The maximum POSIX message queue size
        echo "ulimit -q unlimited" | tee -a $PROF_PATH

        # The maximum number of processes available to a single user
        echo "ulimit -u unlimited" | tee -a $PROF_PATH

        # The maximum amount of virtual memory available to the process
        echo "ulimit -v unlimited" | tee -a $PROF_PATH

        # The maximum number of file locks
        echo "ulimit -x unlimited" | tee -a $PROF_PATH

        # The maximum stack size
        echo "ulimit -s 8192" | tee -a $PROF_PATH

        # The maximum size that may be locked into memory
        echo "ulimit -l unlimited" | tee -a $PROF_PATH

        # Update the limits.conf
        wget "https://raw.githubusercontent.com/TheyCallMeSecond/Linux-Optimizer/main/files/limits.conf" -q -O $LIM_PATH

        echo
        green_msg 'System Limits are Optimized.'
        echo
        sleep 0.5
    }

    ## UFW Optimizations
    ufw_optimizations() {
        echo
        yellow_msg 'Optimizing UFW.'
        echo
        sleep 0.5

        # Purge firewalld to install UFW.
        sudo apt -y purge firewalld

        # Install UFW if it isn't installed.
        sudo apt install -y ufw

        # Disable UFW
        sudo ufw disable

        # Open default ports.
        sudo ufw allow 21
        sudo ufw allow 21/udp
        sudo ufw allow 22
        sudo ufw allow 22/udp
        sudo ufw allow 80
        sudo ufw allow 80/udp
        sudo ufw allow 443
        sudo ufw allow 443/udp
        sleep 0.5

        # Change the UFW config to use System config.
        sed -i 's+/etc/ufw/sysctl.conf+/etc/sysctl.conf+gI' /etc/default/ufw

        # Enable & Reload
        echo "y" | sudo ufw enable
        sudo ufw reload
        echo
        green_msg 'UFW is Optimized.'
        echo
        sleep 0.5
    }

    # Show the Menu
    show_menu() {
        echo
        yellow_msg 'Choose One Option: '
        echo
        green_msg '1 - Apply Everything. (RECOMMENDED)'
        echo
        green_msg '2 - Everything Without Useful Packages.'
        green_msg '3 - Everything Without Useful Packages & UFW Optimizations.'
        green_msg '4 - Update the OS.'
        green_msg '5 - Install Useful Packages.'
        green_msg '6 - Optimize the Network, SSH & System Limits.'
        green_msg '7 - Optimize UFW.'
        echo
        red_msg 'q - Exit.'
        echo
    }

    # Choosing Program
    main() {
        while true; do
            show_menu
            read -p 'Enter Your Choice: ' choice
            case $choice in
            1)
                apply_everything

                echo
                green_msg '========================='
                green_msg 'Done.'
                green_msg '========================='

                ask_reboot
                ;;
            2)
                complete_update
                sleep 0.5

                sysctl_optimizations
                sleep 0.5

                remove_old_ssh_conf
                sleep 0.5

                update_sshd_conf
                sleep 0.5

                limits_optimizations
                sleep 0.5

                ufw_optimizations
                sleep 0.5

                echo
                green_msg '========================='
                green_msg 'Done.'
                green_msg '========================='

                ask_reboot
                ;;
            3)
                complete_update
                sleep 0.5

                sysctl_optimizations
                sleep 0.5

                remove_old_ssh_conf
                sleep 0.5

                update_sshd_conf
                sleep 0.5

                limits_optimizations
                sleep 0.5

                echo
                green_msg '========================='
                green_msg 'Done.'
                green_msg '========================='

                ask_reboot
                ;;
            4)
                complete_update
                sleep 0.5

                echo
                green_msg '========================='
                green_msg 'Done.'
                green_msg '========================='

                ask_reboot
                ;;

            5)
                complete_update
                installations
                sleep 0.5

                echo
                green_msg '========================='
                green_msg 'Done.'
                green_msg '========================='

                ask_reboot
                ;;

            6)

                sysctl_optimizations
                sleep 0.5

                remove_old_ssh_conf
                sleep 0.5

                update_sshd_conf
                sleep 0.5

                limits_optimizations
                sleep 0.5

                echo
                green_msg '========================='
                green_msg 'Done.'
                green_msg '========================='

                ask_reboot
                ;;
            7)
                ufw_optimizations
                sleep 0.5

                echo
                green_msg '========================='
                green_msg 'Done.'
                green_msg '========================='

                ask_reboot
                ;;
            q)
                exit 0
                ;;

            *)
                red_msg 'Wrong input!'
                ;;
            esac
        done
    }

    # Apply Everything
    apply_everything() {

        complete_update
        sleep 0.5

        installations
        sleep 0.5

        enable_packages
        sleep 0.5

        sysctl_optimizations
        sleep 0.5

        remove_old_ssh_conf
        sleep 0.5

        update_sshd_conf
        sleep 0.5

        limits_optimizations
        sleep 0.5

        ufw_optimizations
        sleep 0.5
    }

    main

    exit 0

}

# Main menu loop
while true; do
    echo -e "    \e[91mPlease select an option:\e[0m"
    echo -e
    echo -e "000:\e[95mOptimize Server\e[0m"
    echo -e "00: \e[95mUpdate Sing-Box Core\e[0m"
    echo -------------------------------------------
    echo -e "1:  \e[93mInstall Hysteria2\e[0m"
    echo -e "2:  \e[93mModify Hysteria2 Config\e[0m"
    echo -e "3:  \e[93mShow Hysteria2 Config\e[0m"
    echo -e "4:  \e[93mDisable WARP on Hysteria2\e[0m"
    echo -e "5:  \e[93mUninstall Hysteria2\e[0m"
    echo -------------------------------------------
    echo -e "6:  \e[93mInstall TUIC\e[0m"
    echo -e "7:  \e[93mModify TUIC Config\e[0m"
    echo -e "8:  \e[93mShow TUIC Config\e[0m"
    echo -e "9:  \e[93mDisable WARP on TUIC\e[0m"
    echo -e "10: \e[93mUninstall TUIC\e[0m"
    echo -------------------------------------------
    echo -e "11: \e[93mInstall Reality\e[0m"
    echo -e "12: \e[93mModify Reality Config\e[0m"
    echo -e "13: \e[93mShow Reality Config\e[0m"
    echo -e "14: \e[93mDisable WARP on Reality\e[0m"
    echo -e "15: \e[93mUninstall Reality\e[0m"
    echo -------------------------------------------
    echo -e "16: \e[93mInstall ShadowTLS\e[0m"
    echo -e "17: \e[93mModify ShadowTLS Config\e[0m"
    echo -e "18: \e[93mShow ShadowTLS Config\e[0m"
    echo -e "19: \e[93mDisable WARP on ShadowTLS\e[0m"
    echo -e "20: \e[93mUninstall ShadowTLS\e[0m"
    echo -------------------------------------------
    echo -e "21: \e[93mInstall WARP\e[0m"
    echo -e "22: \e[93mShow WARP Config\e[0m"
    echo -e "23: \e[93mUninstall WARP\e[0m"
    echo -------------------------------------------
    echo -e "0:  \e[95mExit\e[0m"

    read -p "Enter your choice: " user_choice

    case $user_choice in
    000)
        optimize_server
        ;;
    00)
        update_sing-box_core
        ;;
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
        disable_warp_hysteria
        ;;
    5)
        uninstall_hysteria
        ;;
    6)
        install_tuic
        ;;
    7)
        modify_tuic_config
        ;;
    8)
        show_tuic_config
        ;;
    9)
        disable_warp_tuic
        ;;
    10)
        uninstall_tuic
        ;;
    11)
        install_reality
        ;;
    12)
        modify_reality_config
        ;;
    13)
        show_reality_config
        ;;
    14)
        disable_warp_reality
        ;;
    15)
        uninstall_reality
        ;;
    16)
        install_shadowtls
        ;;
    17)
        modify_shadowtls_config
        ;;
    18)
        show_shadowtls_config
        ;;
    19)
        disable_warp_shadowtls
        ;;
    20)
        uninstall_shadowtls
        ;;
    21)
        install_warp
        ;;
    22)
        show_warp_config
        ;;
    23)
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
