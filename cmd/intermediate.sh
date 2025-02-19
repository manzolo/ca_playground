# Funzione per generare la CSR della Intermediate CA
generate_intermediate_ca_csr() {
    local password email cn # Definisci le variabili localmente

    # Usa read -r per leggere l'output delle funzioni di input
    if ! read -r password <<< "$(get_password 'Password chiave privata ITERMEDIATE CA')"; then
        msg_warn "Operazione annullata dall'utente (password)."
        return 1
    fi
    if [ -z "$password" ]; then # Controllo password vuota
        msg_warn "Password non specificata, operazione annullata."
        return 1
    fi

    if ! read -r email <<< "$(get_email 'Email ITERMEDIATE CA')"; then
        msg_warn "Operazione annullata dall'utente (email)."
        return 1
    fi
    if [ -z "$email" ]; then # Controllo email vuota
        msg_warn "Email non specificata, operazione annullata."
        return 1
    fi

    if ! read -r cn <<< "$(get_cn 'CN ITERMEDIATE CA')"; then
        msg_warn "Operazione annullata dall'utente (CN)."
        return 1
    fi
    if [ -z "$cn" ]; then # Controllo CN vuoto
        msg_warn "CN non specificato, operazione annullata."
        return 1
    fi
    msg_warn "Generazione della CSR della Intermediate CA..."
    docker compose run --remove-orphans --rm -e CN_INTERMEDIATE="$cn" -e EMAIL_INTERMEDIATE="$email" -e PASSWORD_INTERMEDIATE="$password" intermediate-ca /scripts/init-intermediate-ca.sh
    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

# Funzione per firmare la CSR del server con la Intermediate CA
sign_server_csr() {
    local password cn
    if ! read cn <<< "$(get_cn 'CN da firmare')"; then
        msg_warn "Operazione annullata dall'utente."
        return 1 
    fi

    # Usa read -r per leggere l'output delle funzioni di input
    if ! read -r password <<< "$(get_password 'Password chiave privata INTERMEDIATE CA')"; then
        msg_warn "Operazione annullata dall'utente (password)."
        return 1
    fi
    if [ -z "$password" ]; then # Controllo password vuota
        msg_warn "Password non specificata, operazione annullata."
        return 1
    fi
    msg_warn "Firma della CSR del server con la Intermediate CA..."
    copy_file "$SHARED_DATA_DIR/server-ca/csr/${cn}.csr.pem" "$SHARED_DATA_DIR/intermediate-ca/csr/"
    docker compose run --remove-orphans --rm -e CN_SERVER="$cn" -e PASSWORD_INTERMEDIATE="$password" intermediate-ca /scripts/sign-server-ca-csr.sh
    copy_file "$SHARED_DATA_DIR/intermediate-ca/certs/${cn}.crt.pem" "$SHARED_DATA_DIR/server-ca/certs/"
    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}