#!/bin/sh

# Installa OpenSSL
apk add --no-cache openssl

# Crea la struttura delle directory
mkdir -p /manzoloCA/intermediate/certs
mkdir -p /manzoloCA/intermediate/crl
mkdir -p /manzoloCA/intermediate/newcerts
mkdir -p /manzoloCA/intermediate/private
mkdir -p /manzoloCA/intermediate/csr
chmod 700 /manzoloCA/intermediate/private
touch /manzoloCA/intermediate/index.txt
echo 1000 > /manzoloCA/intermediate/serial

# Copia il file di configurazione della CA intermedia
cp /etc/ssl/openssl.cnf /manzoloCA/intermediate/openssl.cnf

# Genera la CSR della CA intermedia
openssl req -config /etc/ssl/openssl.cnf \
    -new -keyout /manzoloCA/intermediate/private/CA_INTERMEDIATE.key.pem \
    -out /manzoloCA/intermediate/csr/CA_INTERMEDIATE.csr.pem \
    -subj "/C=IT/ST=Toscana/L=Scarperia e San Piero/O=Manzolo Organization/OU=Manzolo Intermediate CA/CN=Manzolo Intermediate Certification Authority" \
    -passout pass:manzolo1


# Firma la CSR con la CA root
openssl ca -config /manzoloCA/openssl.cnf \
    -extensions v3_intermediate_ca \
    -days 1825 -notext -md sha256 \
    -in /manzoloCA/intermediate/csr/CA_INTERMEDIATE.csr.pem \
    -out /manzoloCA/intermediate/certs/CA_INTERMEDIATE.cert.pem \
    -passin pass:manzolo \
    -batch  # Conferme automatiche

echo "CA Intermedia configurata con successo!"