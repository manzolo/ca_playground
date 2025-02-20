#!/bin/sh

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

# Funzione per gestire gli errori
handle_error() {
    msg_error "Errore: $1" >&2
    exit 1
}

# Installa OpenSSL
apk add --no-cache openssl

if [ -f "$ROOT/certs/intermediate-ca.crt.pem" ]; then
    msg_warn "Il file intermediate-ca.crt.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per la Root CA
    openssl ca -config /etc/ssl/openssl.cnf \
      -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in $ROOT/csr/intermediate-ca.csr.pem \
      -out $ROOT/certs/intermediate-ca.crt.pem \
      -passin pass:${PASSWORD_ROOT} \
      -batch

    if [[ $? -eq 0 ]]; then
        msg_info "Intermediate CA firmata con successo!"
    else
        msg_error "Errore durante la firma della Intermediate CA."
        exit 1 # Esci con un codice di errore
    fi        
fi