#!/bin/bash


msg_warn "Verifica installazione dialog..."

# Rileva se sudo è disponibile
if command -v sudo &> /dev/null; then
  export SUDOCMD="sudo"
else
  export SUDOCMD=""
fi

# Rileva se sudo è disponibile
if command -v dialog &> /dev/null; then
  exit 0
fi

# Rileva il gestore di pacchetti
if command -v apt &> /dev/null; then
  PACKAGEMANAGER="apt"
elif command -v pacman &> /dev/null; then
  PACKAGEMANAGER="pacman"
elif command -v dnf &> /dev/null; then
  PACKAGEMANAGER="dnf"
elif command -v yum &> /dev/null; then
  PACKAGEMANAGER="yum"
elif command -v zypper &> /dev/null; then
  PACKAGEMANAGER="zypper"
else
  echo "Gestore di pacchetti non supportato. Installa 'dialog' manualmente."
  exit 1
fi

# Installa il pacchetto 'dialog'
if [[ "$PACKAGEMANAGER" == "apt" ]]; then
  ${SUDOCMD} apt-get -y update > /dev/null 2>&1 # Aggiorna la lista dei pacchetti (solo per apt)
  ${SUDOCMD} ${SUDOCMD:+sudo }apt-get -y install dialog > /dev/null 2>&1
elif [[ "$PACKAGEMANAGER" == "pacman" ]]; then
  ${SUDOCMD} ${SUDOCMD:+sudo }pacman -Syy --noconfirm dialog > /dev/null 2>&1 # Aggiorna e installa (per pacman)
elif [[ "$PACKAGEMANAGER" == "dnf" ]]; then
  ${SUDOCMD} ${SUDOCMD:+sudo }dnf -y install dialog > /dev/null 2>&1
elif [[ "$PACKAGEMANAGER" == "yum" ]]; then
  ${SUDOCMD} ${SUDOCMD:+sudo }yum -y install dialog > /dev/null 2>&1
elif [[ "$PACKAGEMANAGER" == "zypper" ]]; then
  ${SUDOCMD} ${SUDOCMD:+sudo }zypper --non-interactive install dialog > /dev/null 2>&1
fi

#"Pacchetto 'dialog' installato con successo."