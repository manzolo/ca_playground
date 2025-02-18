#!/bin/sh



if [ -f "/manzoloCA/server/private/server.key.pem" ]; then
    echo "Il file server.key.pem esiste. Non eseguo la generazione"
else
    # Installa OpenSSL
    apk add --no-cache openssl

    # Crea la struttura delle directory
    mkdir -p /manzoloCA/server/certs
    mkdir -p /manzoloCA/server/private
    mkdir -p /manzoloCA/server/csr

    # Genera la CSR per il server
    openssl req -config /etc/ssl/openssl.cnf -new \
        -keyout /manzoloCA/server/private/server.key.pem \
        -out /manzoloCA/server/csr/server.csr.pem \
        -subj "/C=IT/ST=Toscana/L=Scarperia e San Piero/O=Manzolo Organization/OU=Manzolo Web Server/CN=www.example.com" \
        -passout pass:manzoloX

    # Firma la CSR con la CA intermedia
    openssl ca -config /manzoloCA/intermediate/openssl.cnf \
        -extensions v3_server -days 365 -notext -md sha256 \
        -in /manzoloCA/server/csr/server.csr.pem \
        -out /manzoloCA/server/certs/server.cert.pem \
        -passin pass:manzolo1 \
        -batch  # Conferme automatiche
    
    echo "Certificato server generato con successo!"
fi

