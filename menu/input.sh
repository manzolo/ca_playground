#!/bin/bash

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