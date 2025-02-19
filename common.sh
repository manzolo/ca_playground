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

# Funzione per ottenere la password dall'utente (corretta)
get_password() {
  local pwd
  title="$1" # Usa virgolette per il titolo
  pwd=$(dialog --clear --title "Richiesta password" \
    --inputbox "${title}:" 10 60 "" 2>&1 >/dev/tty)
  if [[ $? -ne 0 ]]; then # Controllo annullamento
    return 1 # Fallimento
  fi

  echo "$pwd" # Importante: restituisci la password con echo
}

# Funzione per ottenere EMAIL dall'utente (corretta)
get_email() {
  local email_default="prova@dominio.it"  # Valore predefinito
  local email
  title="$1" # Usa virgolette per il titolo

  email=$(dialog --clear --title "Richiesta email" \
    --inputbox "${title}:" 10 60 "$email_default" 2>&1 >/dev/tty)
  if [[ $? -ne 0 ]]; then # Controllo annullamento
    return 1 # Fallimento
  fi

  echo "$email" # Importante: restituisci l'email con echo
}

# Funzione per ottenere CN dall'utente (corretta)
get_cn() {
  local cn
  title="$1" # Usa virgolette per il titolo

  cn=$(dialog --clear --title "${title}" \
    --inputbox "CN (Common Name):" 10 60 "" 2>&1 >/dev/tty)

  if [[ $? -ne 0 ]]; then  # Controllo annullamento
    return 1 # Fallimento
  fi

  echo "$cn" # Importante: restituisci il CN con echo
}