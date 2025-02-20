#!/bin/sh

set -e
. ./container/common.sh

if [ -f "$ROOT/private/root-ca.key.pem" ]; then
    msg_warn "Il file root-ca.key.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per la Root CA
    mkdir -p $ROOT/certs $ROOT/crl $ROOT/newcerts $ROOT/private $ROOT/csr
    chmod 700 $ROOT/private
    touch $ROOT/index.txt
    echo 1000 > $ROOT/serial

    # Genera la chiave privata della Root CA
    openssl genpkey -algorithm RSA -out $ROOT/private/root-ca.key.pem -aes256 -pass pass:${PASSWORD_ROOT}
    chmod 400 $ROOT/private/root-ca.key.pem

    # Genera il certificato della Root CA
    openssl req -config /etc/ssl/openssl.cnf \
        -key $ROOT/private/root-ca.key.pem \
        -new -x509 -days 7300 -sha256 -extensions v3_ca \
        -out $ROOT/certs/root-ca.crt.pem \
        -subj "/C=${C_ROOT}/ST=${ST_ROOT}/L=${L_ROOT}/O=${O_ROOT}/OU=${OU_ROOT}/CN=${CN_ROOT}/emailAddress=${EMAIL_ROOT}" \
        -passin pass:${PASSWORD_ROOT}

    
    if [[ $? -eq 0 ]]; then
        msg_info "Root CA creata con successo!"
    else
        msg_error "Errore durante la generazione della ROOT CA."
        exit 1 # Esci con un codice di errore
    fi
fi