# Dockerfile
FROM alpine:latest

# Installa le dipendenze necessarie
RUN apk add --no-cache openssl

# Copia gli script
COPY ./cmd /cmd
COPY ./openssl_scripts/root-ca /root-ca
COPY ./openssl_scripts/intermediate-ca /intermediate-ca
COPY ./openssl_scripts/server-ca /server-ca

# Imposta la directory di lavoro
WORKDIR /${ROOT}

# Comando di default (puoi cambiarlo se necessario)
CMD ["sh"]