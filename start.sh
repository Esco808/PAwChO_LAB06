#!/bin/sh

# Uruchomienie aplikacji Go na porcie 8080
/usr/share/nginx/html/myapp &

# Opóźnienie, aby aplikacja Go miała czas na uruchomienie
sleep 5

# Uruchomienie Nginx
nginx -g "daemon off;"

