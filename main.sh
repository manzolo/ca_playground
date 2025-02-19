#!/bin/bash

source ./cmd/common.sh

sudo apt -yqq install dialog > /dev/null 2>&1

set -e

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
                reset_env
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