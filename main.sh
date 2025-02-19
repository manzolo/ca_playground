#!/bin/bash

# Load .env file if it exists
if [ -f .env ]; then
    source .env
fi

sudo ./clean.sh

# Crea la root CA
docker compose run --remove-orphans --rm root-ca /scripts/init-root-ca.sh && docker compose stop root-ca && docker compose rm -f root-ca
docker compose run --remove-orphans --rm intermediate-ca /scripts/init-intermediate-ca.sh && docker compose stop intermediate-ca && docker compose rm -f intermediate-ca

# Cambia i permessi delle directory
echo "Impostazione dei permessi..."
sudo chown -R manzolo:manzolo ./shared-data

# Copia la CSR della Intermediate CA dalla Intermediate CA alla Root CA
cp ./shared-data/intermediate-ca/certs/intermediate-ca.csr.pem ./shared-data/root-ca/csr/

# Firma la CSR della Intermediate CA con la Root CA
echo "Firma della CSR della Intermediate CA con la Root CA..."

docker compose run --remove-orphans --rm root-ca /scripts/sign-intermediate-ca-csr.sh

# Cambia i permessi delle directory
echo "Impostazione dei permessi..."
sudo chown -R manzolo:manzolo ./shared-data

# Copia il certificato della Intermediate CA nella sua directory
echo "Copia del certificato della Intermediate CA..."
cp ./shared-data/root-ca/certs/intermediate-ca.crt.pem ./shared-data/intermediate-ca/certs/

# Crea la CSR del server
echo "Creazione della CSR del server..."
docker compose run --rm server-ca /scripts/init-server-ca.sh && docker compose stop server-ca && docker compose rm -f server-ca

# Copia la CSR del server nella directory della Intermediate CA
echo "Copia della CSR del server nella Intermediate CA..."
cp ./shared-data/server-ca/csr/${CN_SERVER}.csr.pem ./shared-data/intermediate-ca/csr/

docker compose run --rm intermediate-ca /scripts/sign-server-ca-csr.sh && docker compose stop intermediate-ca && docker compose rm -f intermediate-ca

# Copia il certificato del server nella sua directory
echo "Copia del certificato del server..."
cp ./shared-data/intermediate-ca/certs/${CN_SERVER}.crt.pem ./shared-data/server-ca/certs/

# Cambia i permessi delle directory
echo "Impostazione dei permessi..."
sudo chown -R manzolo:manzolo ./shared-data

echo "Processo completato con successo!"
exit 0