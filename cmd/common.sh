#!/bin/bash

source $(dirname $0)/cmd/input.sh
source $(dirname $0)/cmd/root.sh
source $(dirname $0)/cmd/intermediate.sh
source $(dirname $0)/cmd/server.sh

while IFS= read -r line; do
  # Verifica se la riga è un commento o è vuota (ignorando spazi iniziali e finali)
  if [[ ! "$line" =~ ^# ]] && [[ ! "$line" =~ ^[[:space:]]*$ ]]; then
    export "$line"
  fi
done < .env

#read -n 1 -s -r -p "Press any key to continue..."

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

# Funzione per gestire gli errori
handle_error() {
    echo "Errore: $1" >&2
    exit 1
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
reset_env() {
    set_permissions
    $(dirname $0)/cmd/clean.sh || handle_error "Errore durante la pulizia"
    mkdir -p "$SHARED_DATA_DIR" || handle_error "Errore durante la creazione della directory"
    rm -rf $OUTPUT_DATA_DIR
    mkdir -p $OUTPUT_DATA_DIR
}
