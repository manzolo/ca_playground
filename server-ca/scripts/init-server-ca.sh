#!/bin/sh

set -e

NC=$'\033[0m' # No Color
function msg_info() {
  local GREEN=$'\033[0;32m'
  printf "%s\n" "${GREEN}${*}${NC}" >&2
}
function msg_warn() {
  local BROWN=$'\033[0;33m'
  printf "%s\n" "${BROWN}${*}${NC}" >&2
}
function msg_error() {
  local RED=$'\033[0;31m'
  printf "%s\n" "${RED}${*}${NC}" >&2
}

# Installa OpenSSL
apk add --no-cache openssl

if [ -f "/manzoloCA/private/${CN_SERVER}.key.pem" ]; then
    msg_warn "Il file ${CNCN_SERVER}.key.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per il server
    mkdir -p /manzoloCA/certs /manzoloCA/private /manzoloCA/csr
    chmod 700 /manzoloCA/private

    # Genera la chiave privata del server
    openssl genpkey -algorithm RSA -out /manzoloCA/private/${CN_SERVER}.key.pem -aes256 -pass pass:${PASSWORD_SERVER}
    chmod 400 /manzoloCA/private/${CN_SERVER}.key.pem

    # Genera la CSR per il server
    openssl req \
        -key /manzoloCA/private/${CN_SERVER}.key.pem \
        -new -sha256 -out /manzoloCA/csr/${CN_SERVER}.csr.pem \
        -subj "/C=${C_SERVER}/ST=${ST_SERVER}/L=${L_SERVER}/O=${O_SERVER}/OU=${OU_SERVER}/CN=${CN_SERVER}/emailAddress=${EMAIL_SERVER}" \
        -passin pass:${PASSWORD_SERVER}

    echo "Server CSR generata con successo!"
fi
