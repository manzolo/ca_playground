#!/bin/bash

# Carica il file .env se esiste
if [ -f .env ]; then
    source .env
fi

# Variabili importanti
CN_SERVER="${CN_SERVER:-server}"
SHARED_DATA_DIR="${SHARED_DATA_DIR:-./shared-data}"
OUTPUT_DATA_DIR="${OUTPUT_DATA_DIR:-./output}"

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
    sudo chown -R manzolo:manzolo "$SHARED_DATA_DIR" || handle_error "Errore durante l'impostazione dei permessi: $?"
}

# Pulisci l'ambiente
sudo ./clean.sh || handle_error "Errore durante la pulizia"
mkdir -p "$SHARED_DATA_DIR" || handle_error "Errore durante la creazione della directory"
rm -rf $OUTPUT_DATA_DIR
mkdir -p $OUTPUT_DATA_DIR

# Crea la CA radice
run_docker_compose root-ca /scripts/init-root-ca.sh

# Crea la CA intermedia
run_docker_compose intermediate-ca /scripts/init-intermediate-ca.sh

# Imposta i permessi
set_permissions

# Firma la CSR della CA intermedia con la CA radice
echo "Firma della CSR della CA intermedia con la CA radice..."
copy_file "$SHARED_DATA_DIR/intermediate-ca/certs/intermediate-ca.csr.pem" "$SHARED_DATA_DIR/root-ca/csr/"
run_docker_compose root-ca /scripts/sign-intermediate-ca-csr.sh

# Copia il certificato della CA intermedia
echo "Copia del certificato della CA intermedia..."
copy_file "$SHARED_DATA_DIR/root-ca/certs/intermediate-ca.crt.pem" "$SHARED_DATA_DIR/intermediate-ca/certs/"

# Crea la CSR del server
echo "Creazione della CSR del server..."
run_docker_compose server-ca /scripts/init-server-ca.sh

# Firma la CSR del server con la CA intermedia
echo "Firma della CSR del server con la CA intermedia..."
copy_file "$SHARED_DATA_DIR/server-ca/csr/${CN_SERVER}.csr.pem" "$SHARED_DATA_DIR/intermediate-ca/csr/"
run_docker_compose intermediate-ca /scripts/sign-server-ca-csr.sh

# Copia il certificato del server
echo "Copia del certificato del server..."
copy_file "$SHARED_DATA_DIR/intermediate-ca/certs/${CN_SERVER}.crt.pem" "$SHARED_DATA_DIR/server-ca/certs/"

# Copia i certificati nel folder output
copy_file "$SHARED_DATA_DIR/root-ca/certs/root-ca.crt.pem" "$OUTPUT_DATA_DIR"
copy_file "$SHARED_DATA_DIR/intermediate-ca/certs/intermediate-ca.crt.pem" "$OUTPUT_DATA_DIR"
copy_file "$SHARED_DATA_DIR/server-ca/certs/${CN_SERVER}.crt.pem" "$OUTPUT_DATA_DIR"

# Creazione della fullchain.pem
cat "$OUTPUT_DATA_DIR/${CN_SERVER}.crt.pem" "$OUTPUT_DATA_DIR/intermediate-ca.crt.pem" "$OUTPUT_DATA_DIR/root-ca.crt.pem" > "$OUTPUT_DATA_DIR/fullchain.pem" || handle_error "Errore durante la creazione di fullchain.pem"

# Creazione del file contenente solo le CA (root e intermediate)
cat "$OUTPUT_DATA_DIR/root-ca.crt.pem" "$OUTPUT_DATA_DIR/intermediate-ca.crt.pem" > "$OUTPUT_DATA_DIR/ca.pem" || handle_error "Errore durante la creazione di ca.pem"

# Imposta i permessi
set_permissions

echo "Processo completato con successo!"
exit 0