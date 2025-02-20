#!/bin/sh

. ./cmd/__container.sh

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