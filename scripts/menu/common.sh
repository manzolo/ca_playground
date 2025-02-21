#!/bin/bash

source $(dirname $0)/scripts/menu/input.sh
source $(dirname $0)/scripts/menu/root.sh
source $(dirname $0)/scripts/menu/intermediate.sh
source $(dirname $0)/scripts/menu/server.sh

while IFS= read -r line; do
  # Verifica se la riga è un commento o è vuota (ignorando spazi iniziali e finali)
  if [[ ! "$line" =~ ^# ]] && [[ ! "$line" =~ ^[[:space:]]*$ ]]; then
    export "$line"
  fi
done < .env

#read -n 1 -s -r -p "Press any key to continue..."

# Variabili importanti
CN_SERVER="${CN_SERVER:-server}"
DATA_DIR="${DATA_DIR:-./data}"
OUTPUT_DATA_DIR="${OUTPUT_DATA_DIR:-./output}"

if command -v sudo &> /dev/null; then
  export SUDOCMD="sudo"
else
  export SUDOCMD=""
fi

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
    msg_warn "Impostazione dei permessi ${SUDOCMD} $DATA_DIR per $(id -u):$(id -g)..."
    ${SUDOCMD} chown -R $(id -u):$(id -g) "$DATA_DIR" || handle_error "Errore durante l'impostazione dei permessi: $?"
}
reset_env() {
    set_permissions
    $(dirname $0)/scripts/menu/clean.sh || handle_error "Errore durante la pulizia"
    mkdir -p "$DATA_DIR" || handle_error "Errore durante la creazione della directory"
    #rm -rf $OUTPUT_DATA_DIR
    #mkdir -p $OUTPUT_DATA_DIR
}
