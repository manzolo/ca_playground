#!/bin/sh

# Installa OpenSSL
apk add --no-cache openssl

if [ -f "/manzoloCA/private/${CN_SERVER}.key.pem" ]; then
    echo "Il file ${CNCN_SERVER}.key.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per il server
    mkdir -p /manzoloCA/certs /manzoloCA/private /manzoloCA/csr
    chmod 700 /manzoloCA/private

    # Genera la chiave privata del server
    openssl genpkey -algorithm RSA -out /manzoloCA/private/${CN_SERVER}.key.pem -aes256 -pass pass:manzoloxpwd
    chmod 400 /manzoloCA/private/${CN_SERVER}.key.pem

    # Genera la CSR per il server
    openssl req \
        -key /manzoloCA/private/${CN_SERVER}.key.pem \
        -new -sha256 -out /manzoloCA/csr/${CN_SERVER}.csr.pem \
        -subj "/C=${C_SERVER}/ST=${ST_SERVER}/L=${L_SERVER}/O=${O_SERVER}/OU=${OU_SERVER}/CN=${CN_SERVER}/emailAddress=${EMAIL_SERVER}" \
        -passin pass:manzoloxpwd

    echo "Server CSR generata con successo!"
fi
