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

if [ -f "/manzoloCA/certs/${CN_SERVER}.p12" ]; then
    msg_warn "Il file ${CN_SERVER}.p12 esiste. Non eseguo la generazione"
else
    # Crea la directory per il server
    mkdir -p /manzoloCA/certs

    openssl pkcs12 -export \
    -inkey /manzoloCA/private/${CN_SERVER}.key.pem \
    -in /manzoloCA/certs/${CN_SERVER}.crt.pem \
    -certfile /manzoloCA/certs/ca-chain.crt.pem \
    -out /manzoloCA/certs/${CN_SERVER}.p12 \
    -passout pass:${PASSWORD_SERVER} \
    -passin pass:${PASSWORD_SERVER}

    echo "Server P12 generato con successo!"
fi
