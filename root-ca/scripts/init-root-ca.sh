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

if [ -f "/manzoloCA/private/root-ca.key.pem" ]; then
    msg_warn "Il file root-ca.key.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per la Root CA
    mkdir -p /manzoloCA/certs /manzoloCA/crl /manzoloCA/newcerts /manzoloCA/private /manzoloCA/csr
    chmod 700 /manzoloCA/private
    touch /manzoloCA/index.txt
    echo 1000 > /manzoloCA/serial

    # Genera la chiave privata della Root CA
    openssl genpkey -algorithm RSA -out /manzoloCA/private/root-ca.key.pem -aes256 -pass pass:${PASSWORD_ROOT}
    chmod 400 /manzoloCA/private/root-ca.key.pem

    # Genera il certificato della Root CA
    openssl req -config /etc/ssl/openssl.cnf \
        -key /manzoloCA/private/root-ca.key.pem \
        -new -x509 -days 7300 -sha256 -extensions v3_ca \
        -out /manzoloCA/certs/root-ca.crt.pem \
        -subj "/C=${C_ROOT}/ST=${ST_ROOT}/L=${L_ROOT}/O=${O_ROOT}/OU=${OU_ROOT}/CN=${CN_ROOT}/emailAddress=${EMAIL_ROOT}" \
        -passin pass:${PASSWORD_ROOT}

    
    if [[ $? -eq 0 ]]; then
        msg_info "Root CA creata con successo!"
    else
        msg_error "Errore durante la generazione della ROOT CA."
        exit 1 # Esci con un codice di errore
    fi
fi