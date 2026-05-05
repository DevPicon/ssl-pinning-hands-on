#!/bin/bash

set -e

CERTS_DIR="backend/certs"
CERT_FILE="$CERTS_DIR/server.pem"
KEY_FILE="$CERTS_DIR/key.pem"
CER_FILE="$CERTS_DIR/server.cer"
KEYSTORE_FILE="$CERTS_DIR/keystore.p12"

mkdir -p "$CERTS_DIR"

echo "Generating local self-signed certificate..."

openssl req -x509 -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -days 365 \
  -nodes \
  -subj "/CN=localhost"

echo "Exporting certificate as .cer for iOS..."

openssl x509 \
  -outform der \
  -in "$CERT_FILE" \
  -out "$CER_FILE"

echo "Generating PKCS12 keystore for Ktor..."

openssl pkcs12 -export \
  -in "$CERT_FILE" \
  -inkey "$KEY_FILE" \
  -out "$KEYSTORE_FILE" \
  -name ktor \
  -password pass:password

echo "Starting Docker environment..."

docker compose up --build -d

echo ""
echo "Backend running:"
echo "  HTTPS: https://localhost:8443"
echo ""
echo "Test it with:"
echo "  curl -k https://localhost:8443/health"
echo ""
echo "Android Emulator URL:"
echo "  https://10.0.2.2:8443"