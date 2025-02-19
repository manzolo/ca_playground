# Funzione per generare la CSR del server (modificata)
generate_server_csr() {
    local cn
    if ! read cn <<< "$(get_cn 'Server CN')"; then
        msg_warn "Operazione annullata dall'utente."
        return 1 
    fi
    local email
    if ! read email <<< "$(get_email 'Server Email')"; then  
        msg_warn "Operazione annullata dall'utente."
        return 1 
    fi

    msg_warn "Generazione della CSR del server per CN: $cn, Email: $email..."

    # Passa CN ed EMAIL al container usando variabili d'ambiente
    docker compose run --remove-orphans --rm -e CN_SERVER="$cn" -e EMAIL_SERVER="$email" server-ca /scripts/init-server-ca.sh
    docker compose stop server-ca && docker compose rm -f server-ca

    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}