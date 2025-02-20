# Funzione per generare la Root CA (corretta)
generate_root_ca() {
    local password email cn # Definisci le variabili localmente

    # Usa read -r per leggere l'output delle funzioni di input
    if ! read -r password <<< "$(get_password 'Password chiave privata ROOT CA')"; then
        msg_warn "Operazione annullata dall'utente (password)."
        return 1
    fi
    if [ -z "$password" ]; then # Controllo password vuota
        msg_warn "Password non specificata, operazione annullata."
        return 1
    fi

    if ! read -r email <<< "$(get_email 'Email ROOT CA')"; then
        msg_warn "Operazione annullata dall'utente (email)."
        return 1
    fi
    if [ -z "$email" ]; then # Controllo email vuota
        msg_warn "Email non specificata, operazione annullata."
        return 1
    fi

    if ! read -r cn <<< "$(get_cn 'CN ROOT CA')"; then
        msg_warn "Operazione annullata dall'utente (CN)."
        return 1
    fi
    if [ -z "$cn" ]; then # Controllo CN vuoto
        msg_warn "CN non specificato, operazione annullata."
        return 1
    fi

    msg_warn "Generazione della Root CA con CN: $cn, Email: $email..."

    # Passa le variabili *correttamente* a docker compose run
    docker compose run --remove-orphans --rm -e CN_ROOT="$cn" -e EMAIL_ROOT="$email" -e PASSWORD_ROOT="$password" root-ca /scripts/init-root-ca.sh

    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

# Funzione per firmare la CSR della Intermediate CA con la Root CA
sign_intermediate_ca_csr() {
    local password

    # Usa read -r per leggere l'output delle funzioni di input
    if ! read -r password <<< "$(get_password 'Password chiave privata ROOT CA')"; then
        msg_warn "Operazione annullata dall'utente (password)."
        return 1
    fi
    if [ -z "$password" ]; then # Controllo password vuota
        msg_warn "Password non specificata, operazione annullata."
        return 1
    fi
    msg_warn "Firma della CSR della Intermediate CA con la Root CA..."
    copy_file "$DATA_DIR/intermediate-ca/certs/intermediate-ca.csr.pem" "$DATA_DIR/root-ca/csr/"
    docker compose run --remove-orphans --rm -e CN_ROOT="" -e EMAIL_ROOT="" -e PASSWORD_ROOT="$password" root-ca /scripts/sign-intermediate-ca-csr.sh
    copy_file "$DATA_DIR/root-ca/certs/intermediate-ca.crt.pem" "$DATA_DIR/intermediate-ca/certs/"
    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}