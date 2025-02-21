# Dockerfile
FROM alpine:latest

# Installa le dipendenze necessarie
RUN apk add --no-cache openssl

# Copia gli script
COPY ./scripts/menu /menu
COPY ./scripts/container /container
COPY ./scripts/openssl_scripts/root-ca /root-ca
COPY ./scripts/openssl_scripts/intermediate-ca /intermediate-ca
COPY ./scripts/openssl_scripts/server-ca /server-ca

# Imposta la directory di lavoro
WORKDIR /${ROOT}

# Comando di default (puoi cambiarlo se necessario)
CMD ["sh"]