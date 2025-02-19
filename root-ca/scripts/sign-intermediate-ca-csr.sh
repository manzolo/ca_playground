#!/bin/sh

# Installa OpenSSL
apk add --no-cache openssl

if [ -f "/manzoloCA/certs/intermediate-ca.crt.pem" ]; then
    echo "Il file intermediate-ca.crt.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per la Root CA
    openssl ca -config /etc/ssl/openssl.cnf \
      -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in /manzoloCA/csr/intermediate-ca.csr.pem \
      -out /manzoloCA/certs/intermediate-ca.crt.pem \
      -passin pass:manzolopwd \
      -batch

    echo "Intermediate CA firmata con successo!"
fi