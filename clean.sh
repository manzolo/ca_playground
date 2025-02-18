#!/bin/bash

# Directory da pulire
DIRECTORIES=(
  "shared-data/root-ca"
  "shared-data/intermediate-ca"
  "shared-data/server-ca"
)

# Estensioni dei file da cancellare
EXTENSIONS=("csr" "key" "crt" "pem" "txt" "cnf" "old" "attr")

# Cancella i file con le estensioni specificate
for dir in "${DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo "Pulizia della directory: $dir"
    for ext in "${EXTENSIONS[@]}"; do
      find "$dir" -type f -name "*.$ext" -exec rm -v {} \;
    done
  else
    echo "Directory $dir non trovata, saltando..."
  fi
done

FILES=("serial")

# Cancella i file con le estensioni specificate
for dir in "${DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo "Pulizia della directory: $dir"
    for file in "${FILES[@]}"; do
      find "$dir" -type f -name "$file" -exec rm -v {} \;
    done
  else
    echo "Directory $dir non trovata, saltando..."
  fi
done

echo "Pulizia completata!"