#!/bin/sh

set -e

. ./cmd/__container.sh

if [ -f "$ROOT/certs/${CN_SERVER}.p12" ]; then
    msg_warn "Il file ${CN_SERVER}.p12 esiste. Non eseguo la generazione"
else
    # Crea la directory per il server
    mkdir -p $ROOT/certs

    openssl pkcs12 -export \
    -inkey $ROOT/private/${CN_SERVER}.key.pem \
    -in $ROOT/certs/${CN_SERVER}.crt.pem \
    -certfile $ROOT/certs/ca-chain.crt.pem \
    -out $ROOT/certs/${CN_SERVER}.p12 \
    -name "${CN_SERVER}" \
    -passout pass:${PASSWORD_SERVER} \
    -passin pass:${PASSWORD_SERVER}
    
    #openssl pkcs12 -info -in $ROOT/certs/${CN_SERVER}.p12 -passin pass:${PASSWORD_SERVER}
    if [[ $? -eq 0 ]]; then
        msg_info "${CN_SERVER}.P12 generato con successo!"
    else
        msg_error "Errore durante la creazione del file ${CN_SERVER}.p12"
        exit 1 # Esci con un codice di errore
    fi     
fi
