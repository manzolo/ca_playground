# Funzione per generare la CSR del server (modificata)
generate_server_csr() {
    local password cn email # Definisci le variabili localmente

    if ! read cn <<< "$(get_cn 'Server CN')"; then
        msg_warn "Operazione annullata dall'utente."
        return 1 
    fi
    # Usa read -r per leggere l'output delle funzioni di input
    if ! read -r password <<< "$(get_password 'Password chiave privata '${cn})"; then
        msg_warn "Operazione annullata dall'utente (password)."
        return 1
    fi
    if [ -z "$password" ]; then # Controllo password vuota
        msg_warn "Password non specificata, operazione annullata."
        return 1
    fi
    if ! read email <<< "$(get_email 'Server Email')"; then  
        msg_warn "Operazione annullata dall'utente."
        return 1 
    fi

    msg_warn "Generazione della CSR del server per CN: $cn, Email: $email..."

    # Passa CN ed EMAIL al container usando variabili d'ambiente
    docker compose run --remove-orphans --rm -e CN_SERVER="$cn" -e EMAIL_SERVER="$email" -e PASSWORD_SERVER="$password" server-ca /scripts/init-server-ca.sh
    docker compose stop server-ca && docker compose rm -f server-ca

    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

generate_server_p12() {
    local password cn # Definisci le variabili localmente

    if ! read cn <<< "$(get_cn 'Server CN')"; then
        msg_warn "Operazione annullata dall'utente."
        return 1 
    fi
    if [ -f "$SHARED_DATA_DIR/server-ca/certs/$cn.p12" ]; then
        msg_warn "Attenzione, è già presente il file $SHARED_DATA_DIR/server-ca/certs/$cn.p12"
        read -n 1 -s -r -p "Press any key to continue..."
        return
    fi
    # Usa read -r per leggere l'output delle funzioni di input
    if ! read -r password <<< "$(get_password 'Password chiave privata '${cn})"; then
        msg_warn "Operazione annullata dall'utente (password)."
        return 1
    fi
    if [ -z "$password" ]; then # Controllo password vuota
        msg_warn "Password non specificata, operazione annullata."
        return 1
    fi

    copy_file "$SHARED_DATA_DIR/root-ca/certs/root-ca.crt.pem" "$SHARED_DATA_DIR/server-ca/certs/"
    copy_file "$SHARED_DATA_DIR/intermediate-ca/certs/intermediate-ca.crt.pem" "$SHARED_DATA_DIR/server-ca/certs/"
    cat "$SHARED_DATA_DIR/server-ca/certs/intermediate-ca.crt.pem" "$SHARED_DATA_DIR/server-ca/certs/root-ca.crt.pem" > "$SHARED_DATA_DIR/server-ca/certs/ca-chain.crt.pem"
    msg_warn "Generazione del p12 del server per CN: $cn"
    
    set_permissions
    
    # Passa CN al container usando variabili d'ambiente
    docker compose run --remove-orphans --rm -e CN_SERVER="$cn" -e PASSWORD_SERVER="$password" -e EMAIL_SERVER="" server-ca /scripts/p12-server-ca.sh 
    docker compose stop server-ca && docker compose rm -f server-ca
    set_permissions

    read -n 1 -s -r -p "Press any key to continue..."
    echo
}