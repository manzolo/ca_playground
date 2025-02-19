#!/bin/sh

# Installa OpenSSL
apk add --no-cache openssl

if [ -f "/manzoloCA/certs/${CN_SERVER}.crt.pem" ]; then
    echo "Il file ${CN_SERVER}.crt.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per la Root CA
    openssl ca \
      -extensions v3_server \
      -days 375 -notext -md sha256 \
      -in /manzoloCA/csr/${CN_SERVER}.csr.pem \
      -out /manzoloCA/certs/${CN_SERVER}.crt.pem \
      -passin pass:manzolo1pwd \
      -batch

    echo "Intermediate CA firmata con successo!"
fi