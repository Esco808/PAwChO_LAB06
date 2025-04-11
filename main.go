package main

import (
	"fmt"
	"net"
	"net/http"
	"os"
)

var version = "unknown"

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Pobranie adresu IP serwera
		addrs, err := net.InterfaceAddrs()
		if err != nil {
			http.Error(w, "Błąd pobierania adresu IP", http.StatusInternalServerError)
			return
		}
		var serverIP string
		for _, addr := range addrs {
			if ipNet, ok := addr.(*net.IPNet); ok && !ipNet.IP.IsLoopback() {
				serverIP = ipNet.IP.String()
				break
			}
		}

		// Pobranie nazwy hosta
		hostname, err := os.Hostname()
		if err != nil {
			hostname = "unknown"
		}

		fmt.Fprintf(w, "Server IP: %s\n", serverIP)
		fmt.Fprintf(w, "Hostname: %s\n", hostname)
		fmt.Fprintf(w, "Version: %s\n", version)
	})

	http.ListenAndServe(":8080", nil)
}
