# syntax=docker/dockerfile:1
# Etap 1: Budowanie aplikacji Go
FROM scratch AS builder

# Dodanie systemu plików Alpine do etapu budowy
ADD alpine-minirootfs-3.21.3-x86_64.tar.gz / 

# Ustawienie katalogu roboczego
WORKDIR /app

# Instalacja Go, GCC, i libc-dev w Alpine (potrzebne do kompilacji)
RUN apk add --no-cache go libc-dev gcc openssh-client git tar

# Pobranie klucza publicznego z github
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Klonowanie repozytorium przez ssh
RUN --mount=type=ssh git clone git@github.com:Esco808/PAwChO_LAB06.git

WORKDIR /app/PAwChO_LAB06

# Inicjalizacja modułu Go
RUN go mod init myapp && go mod tidy

# Budowanie aplikacji Go statycznie
ARG VERSION=unknown
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/myapp -ldflags="-X main.version=$VERSION"

# Etap 2: Serwer HTTP Nginx
FROM nginx:latest

# Skopiowanie aplikacji Go z etapu budowania
COPY --from=builder /app/myapp /usr/share/nginx/html/

# Nadanie uprawnień do wykonania aplikacji Go
RUN chmod +x /usr/share/nginx/html/myapp

# Skopiowanie pliku konfiguracyjnego Nginx
COPY --from=builder /app/PAwChO_LAB06/default.conf /etc/nginx/conf.d/default.conf

# Skrypt uruchamiający aplikację Go i Nginx
COPY --from=builder /app/PAwChO_LAB06/start.sh /start.sh
RUN chmod +x /start.sh

# Sprawdzanie poprawności działania serwera
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost || exit 1

# Uruchomienie skryptu, który najpierw uruchomi aplikację Go, a potem Nginx
CMD ["/start.sh"]
