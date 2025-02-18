#!/bin/sh

# Installa OpenSSL
apk add --no-cache openssl

# Crea la struttura delle directory
mkdir -p /manzoloCA/certs
mkdir -p /manzoloCA/crl
mkdir -p /manzoloCA/newcerts
mkdir -p /manzoloCA/private
chmod 700 /manzoloCA/private
touch /manzoloCA/index.txt
echo 1000 > /manzoloCA/serial

# Copia il file di configurazione della CA root
cp /etc/ssl/openssl.cnf /manzoloCA/openssl.cnf

# Genera la CA root
openssl req -config /manzoloCA/openssl.cnf -new -x509 -days 3650 -keyout /manzoloCA/private/CA_ROOT.key.pem -out /manzoloCA/certs/CA_ROOT.cert.pem -subj "/C=IT/ST=Toscana/L=Scarperia e San Piero/O=Manzolo Organization/OU=Manzolo Root CA/CN=Manzolo Root Certification Authority"

echo "CA Root configurata con successo!"