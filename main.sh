#!/bin/bash

set -e

source ./menu/common.sh

msg_warn "installazione prerequisiti..."
sudo apt -yqq install dialog > /dev/null 2>&1

msg_info "Creazione immagine docker"
docker compose up --build > /dev/null 2>&1

msg_warn "Avvio menu in corso..."

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
            6 "Genera P12 Server" \
            7 "Reset" \
            8 "Esci" \
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
                generate_server_p12
                ;;
            7)
                reset_env
                ;;
            8)
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