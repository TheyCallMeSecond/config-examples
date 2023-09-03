#!/usr/bin/env bash

domain=$(openssl rand -hex 8)

openssl genrsa -out hysteria.ca.key 2048

openssl req -new -x509 -days 3650 -key hysteria.ca.key -subj "/C=CN/ST=GD/L=SZ/O=Hysteria, Inc./CN=Hysteria Root CA" -out hysteria.ca.crt

openssl req -newkey rsa:2048 -nodes -keyout hysteria.server.key -subj "/C=CN/ST=GD/L=SZ/O=Hysteria, Inc./CN=*.${domain}.com" -out hysteria.server.csr

openssl x509 -req -extfile <(printf "subjectAltName=DNS:${domain}.com,DNS:www.${domain}.com") -days 3650 -in hysteria.server.csr -CA hysteria.ca.crt -CAkey hysteria.ca.key -CAcreateserial -out hysteria.server.crt


