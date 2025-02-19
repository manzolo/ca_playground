#!/bin/bash

source ./cmd/common.sh

sudo apt -yqq install dialog > /dev/null 2>&1

set -e

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
    copy_file "$SHARED_DATA_DIR/intermediate-ca/certs/intermediate-ca.csr.pem" "$SHARED_DATA_DIR/root-ca/csr/"
    docker compose run --remove-orphans --rm -e CN_ROOT="" -e EMAIL_ROOT="" -e PASSWORD_ROOT="$password" root-ca /scripts/sign-intermediate-ca-csr.sh
    copy_file "$SHARED_DATA_DIR/root-ca/certs/intermediate-ca.crt.pem" "$SHARED_DATA_DIR/intermediate-ca/certs/"
    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

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

# Menu grafico
show_menu() {
    while true; do
        choice=$(dialog --clear --backtitle "Menu di gestione CA" \
            --title "Seleziona un'opzione" \
            --menu "Cosa vuoi fare?" 20 60 8 \
            1 "Genera Root CA" \
            2 "Genera CSR Intermediate CA" \
            3 "Firma CSR Intermediate CA" \
            4 "Genera CSR Server" \
            5 "Firma CSR Server" \
            6 "Reset" \
            7 "Esci" \
            2>&1 >/dev/tty)

        case $choice in
            1)
                generate_root_ca
                ;;
            2)
                generate_intermediate_ca_csr
                ;;
            3)
                sign_intermediate_ca_csr
                ;;
            4)
                generate_server_csr
                ;;
            5)
                sign_server_csr
                ;;
            6)
                set_permissions
                ./cmd/clean.sh || handle_error "Errore durante la pulizia"
                mkdir -p "$SHARED_DATA_DIR" || handle_error "Errore durante la creazione della directory"
                rm -rf $OUTPUT_DATA_DIR
                mkdir -p $OUTPUT_DATA_DIR
                ;;
            7)
                echo "Uscita..."
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done
}

# Mostra il menu
show_menu