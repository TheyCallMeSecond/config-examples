#!/usr/bin/env bash

openssl genrsa -out ca.key 2048

openssl req -new -x509 -days 3650 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=Apple Root CA" -out ca.crt

openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Apple, Inc./CN=*.apple.com" -out server.csr

openssl x509 -req -extfile <(printf "subjectAltName=DNS:apple.com,DNS:www.apple.com") -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt

