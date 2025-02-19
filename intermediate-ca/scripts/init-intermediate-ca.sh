#!/bin/sh

# Installa OpenSSL
apk add --no-cache openssl

if [ -f "/manzoloCA/private/intermediate-ca.key.pem" ]; then
    echo "Il file CA_INTERMEDIATE.key.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per la Intermediate CA
    mkdir -p /manzoloCA/certs /manzoloCA/crl /manzoloCA/newcerts /manzoloCA/private /manzoloCA/csr
    chmod 700 /manzoloCA/private
    touch /manzoloCA/index.txt
    echo 1000 > /manzoloCA/serial

    # Genera la chiave privata della Intermediate CA
    openssl genpkey -algorithm RSA -out /manzoloCA/private/intermediate-ca.key.pem -aes256 -pass pass:manzolo1pwd
    chmod 400 /manzoloCA/private/intermediate-ca.key.pem

    # Genera la CSR per la Intermediate CA
    openssl req -config /etc/ssl/openssl.cnf \
        -key /manzoloCA/private/intermediate-ca.key.pem \
        -new -sha256 -out /manzoloCA/certs/intermediate-ca.csr.pem \
        -subj "/C=${C_INTERMEDIATE}/ST=${ST_INTERMEDIATE}/L=${L_INTERMEDIATE}/O=${O_INTERMEDIATE}/OU=${OU_INTERMEDIATE}/CN=${CN_INTERMEDIATE}/emailAddress=${EMAIL_INTERMEDIATE}" \
        -passin pass:manzolo1pwd

    echo "Intermediate CA CSR generata con successo!"

    
fi