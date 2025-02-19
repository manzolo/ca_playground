#!/bin/bash

# Load .env file if it exists
if [[ -f .env ]]; then
  export $(grep -v '^#' .env | xargs) # Export variables from .env, ignoring comments
fi

# Variabili importanti
CN_SERVER="${CN_SERVER:-server}"
SHARED_DATA_DIR="${SHARED_DATA_DIR:-./shared-data}"
OUTPUT_DATA_DIR="${OUTPUT_DATA_DIR:-./output}"

NC=$'\033[0m' # No Color
function msg_info() {
  local GREEN=$'\033[0;32m'
  printf "%s\n" "${GREEN}${*}${NC}" >&2
}
function msg_warn() {
  local BROWN=$'\033[0;33m'
  printf "%s\n" "${BROWN}${*}${NC}" >&2
}
function msg_error() {
  local RED=$'\033[0;31m'
  printf "%s\n" "${RED}${*}${NC}" >&2
}

sudo apt -yqq install dialog > /dev/null 2>&1

set -e

# Funzione per gestire gli errori
handle_error() {
    echo "Errore: $1" >&2
    exit 1
}

# Funzione per eseguire un comando docker compose e gestire gli errori
run_docker_compose() {
    docker compose run --remove-orphans --rm "$@" || handle_error "Errore durante l'esecuzione di docker compose: $?"
    docker compose stop "$1" && docker compose rm -f "$1"
}

# Funzione per copiare un file e gestire gli errori
copy_file() {
    cp "$1" "$2" || handle_error "Errore durante la copia del file: $?"
}

# Funzione per impostare i permessi
set_permissions() {
    echo "Impostazione dei permessi..."
    sudo chown -R $(id -u):$(id -g) "$SHARED_DATA_DIR" || handle_error "Errore durante l'impostazione dei permessi: $?"
}

# Funzione per generare la Root CA
generate_root_ca() {
    msg_warn "Generazione della Root CA..."
    run_docker_compose root-ca /scripts/init-root-ca.sh
    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

# Funzione per generare la CSR della Intermediate CA
generate_intermediate_ca_csr() {
    msg_warn "Generazione della CSR della Intermediate CA..."
    run_docker_compose intermediate-ca /scripts/init-intermediate-ca.sh
    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

# Funzione per firmare la CSR della Intermediate CA con la Root CA
sign_intermediate_ca_csr() {
    msg_warn "Firma della CSR della Intermediate CA con la Root CA..."
    copy_file "$SHARED_DATA_DIR/intermediate-ca/certs/intermediate-ca.csr.pem" "$SHARED_DATA_DIR/root-ca/csr/"
    run_docker_compose root-ca /scripts/sign-intermediate-ca-csr.sh
    copy_file "$SHARED_DATA_DIR/root-ca/certs/intermediate-ca.crt.pem" "$SHARED_DATA_DIR/intermediate-ca/certs/"
    set_permissions
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

# Funzione per ottenere EMAIL dall'utente
get_server_email() {
  local email_default="prova@dominio.it"  # Valore predefinito
  local email

  email=$(dialog --clear --title "Informazioni Server" \
    --inputbox "Email:" 10 60 "$email_default" 2>&1 >/dev/tty)
  if [[ $? -ne 0 ]]; then # Controllo annullamento
    return 1 # Fallimento
  fi

  echo "$email"
}

# Funzione per ottenere CN dall'utente
get_server_cn() {
  local cn_default="www.manzolo.it"  # Valore predefinito
  local cn

  cn=$(dialog --clear --title "Informazioni Server" \
    --inputbox "CN (Common Name):" 10 60 "$cn_default" 2>&1 >/dev/tty)

  if [[ $? -ne 0 ]]; then  # Controllo annullamento
    return 1 # Fallimento
  fi

  echo "$cn"
}

# Funzione per ottenere la password dall'utente
get_password() {
  local pwd

  pwd=$(dialog --clear --title "Informazioni CA" \
    --inputbox "Password chiave privata CA:" 10 60 "" 2>&1 >/dev/tty)
  if [[ $? -ne 0 ]]; then # Controllo annullamento
    return 1 # Fallimento
  fi

  echo "$pwd"
}

# Funzione per generare la CSR del server (modificata)
generate_server_csr() {
    local cn
    if ! read cn <<< "$(get_server_cn)"; then
        msg_warn "Operazione annullata dall'utente."
        return 1 
    fi
    local email
    if ! read email <<< "$(get_server_email)"; then  
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
    if ! read cn <<< "$(get_server_cn)"; then
        msg_warn "Operazione annullata dall'utente."
        return 1 
    fi      
    msg_warn "Firma della CSR del server con la Intermediate CA..."
    copy_file "$SHARED_DATA_DIR/server-ca/csr/${cn}.csr.pem" "$SHARED_DATA_DIR/intermediate-ca/csr/"
    docker compose run --remove-orphans --rm -e CN_SERVER="$cn" intermediate-ca /scripts/sign-server-ca-csr.sh
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
                ./clean.sh || handle_error "Errore durante la pulizia"
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