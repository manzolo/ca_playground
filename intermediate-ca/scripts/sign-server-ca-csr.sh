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

if [ -f "/manzoloCA/certs/${CN_SERVER}.crt.pem" ]; then
    msg_warn "Il file ${CN_SERVER}.crt.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per la Root CA
    openssl ca \
      -extensions v3_server \
      -days 375 -notext -md sha256 \
      -in /manzoloCA/csr/${CN_SERVER}.csr.pem \
      -out /manzoloCA/certs/${CN_SERVER}.crt.pem \
      -passin pass:${PASSWORD_INTERMEDIATE} \
      -batch

    msg_warn "Intermediate CA firmata con successo!"
fi