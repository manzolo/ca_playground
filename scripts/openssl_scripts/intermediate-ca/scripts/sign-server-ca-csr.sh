#!/bin/sh

set -e

. ./container/common.sh

if [ -f "$ROOT/certs/${CN_SERVER}.crt.pem" ]; then
    msg_warn "Il file ${CN_SERVER}.crt.pem esiste. Non eseguo la generazione"
else
    if [ -f "$ROOT/csr/${CN_SERVER}.csr.pem" ]; then
      # Crea la directory per la Root CA
      openssl ca \
        -extensions v3_server \
        -days 375 -notext -md sha256 \
        -in $ROOT/csr/${CN_SERVER}.csr.pem \
        -out $ROOT/certs/${CN_SERVER}.crt.pem \
        -passin pass:${PASSWORD_INTERMEDIATE} \
        -batch

      if [[ $? -eq 0 ]]; then
          msg_info "Certificato server firmato dalla Intermediate CA con successo!"
      else
          msg_error "Errore durante la firma del certificato server firmato dalla Intermediate CA"
          exit 1 # Esci con un codice di errore
      fi
    else
      msg_warn "Attenzione, non è presente la CSR $ROOT/csr/${CN_SERVER}.csr.pem"
    fi
fi