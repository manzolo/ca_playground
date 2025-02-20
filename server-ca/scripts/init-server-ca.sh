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

if [ -f "$ROOT/private/${CN_SERVER}.key.pem" ]; then
    msg_warn "Il file ${CN_SERVER}.key.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per il server
    mkdir -p $ROOT/certs $ROOT/private $ROOT/csr
    chmod 700 $ROOT/private

    # Genera la chiave privata del server
    openssl genpkey -algorithm RSA -out $ROOT/private/${CN_SERVER}.key.pem -aes256 -pass pass:${PASSWORD_SERVER}
    chmod 400 $ROOT/private/${CN_SERVER}.key.pem

    # Genera la CSR per il server
    openssl req \
        -key $ROOT/private/${CN_SERVER}.key.pem \
        -new -sha256 -out $ROOT/csr/${CN_SERVER}.csr.pem \
        -subj "/C=${C_SERVER}/ST=${ST_SERVER}/L=${L_SERVER}/O=${O_SERVER}/OU=${OU_SERVER}/CN=${CN_SERVER}/emailAddress=${EMAIL_SERVER}" \
        -passin pass:${PASSWORD_SERVER}

    if [[ $? -eq 0 ]]; then
        msg_info "Server CSR generata con successo!"
    else
        msg_error "Errore durante la generazione della Server CSR."
        exit 1 # Esci con un codice di errore
    fi
fi
