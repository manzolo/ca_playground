#!/bin/sh

. ./container/common.sh

if [ -f "$ROOT/private/intermediate-ca.key.pem" ]; then
    msg_warn "Il file intermediate-ca.key.pem esiste. Non eseguo la generazione"
else
    # Crea la directory per la Intermediate CA
    mkdir -p $ROOT/certs $ROOT/crl $ROOT/newcerts $ROOT/private $ROOT/csr
    chmod 700 $ROOT/private
    touch $ROOT/index.txt
    echo 1000 > $ROOT/serial

    # Genera la chiave privata della Intermediate CA
    openssl genpkey -algorithm RSA -out $ROOT/private/intermediate-ca.key.pem -aes256 -pass pass:${PASSWORD_INTERMEDIATE}
    if [[ $? -eq 0 ]]; then
        msg_info "Chiave private della Intermediate CA generata con successo!"
    else
        msg_error "Errore durante la generazione della chiave private della Intermediate CA."
        exit 1 # Esci con un codice di errore
    fi
    
    chmod 400 $ROOT/private/intermediate-ca.key.pem

    # Genera la CSR per la Intermediate CA
    openssl req -config /etc/ssl/openssl.cnf \
        -key $ROOT/private/intermediate-ca.key.pem \
        -new -sha256 -out $ROOT/certs/intermediate-ca.csr.pem \
        -subj "/C=${C_INTERMEDIATE}/ST=${ST_INTERMEDIATE}/L=${L_INTERMEDIATE}/O=${O_INTERMEDIATE}/OU=${OU_INTERMEDIATE}/CN=${CN_INTERMEDIATE}/emailAddress=${EMAIL_INTERMEDIATE}" \
        -passin pass:${PASSWORD_INTERMEDIATE}

    
    if [[ $? -eq 0 ]]; then
        msg_info "Intermediate CA CSR generata con successo!"
    else
        msg_error "Errore durante la generazione della INTERMEDIATE CA."
        exit 1 # Esci con un codice di errore
    fi
    
fi