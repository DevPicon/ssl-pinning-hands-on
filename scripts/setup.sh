#!/bin/bash

set -e

CERTS_DIR="backend/certs"
CERT_FILE="$CERTS_DIR/server.pem"
KEY_FILE="$CERTS_DIR/key.pem"
CER_FILE="$CERTS_DIR/server.cer"
KEYSTORE_FILE="$CERTS_DIR/keystore.p12"

ANDROID_RAW_DIR="android/app/src/main/res/raw"
ANDROID_CERT_FILE="$ANDROID_RAW_DIR/server.cer"

IOS_APP_DIR="ios/SslPinningIos/SslPinningIos"
IOS_CERT_FILE="$IOS_APP_DIR/server.cer"

mkdir -p "$CERTS_DIR"

if [[ -f "$CERT_FILE" && -f "$KEY_FILE" && -f "$CER_FILE" && -f "$KEYSTORE_FILE" ]]; then
  echo "Certificates already exist. Skipping generation."
else
  echo "Generating local self-signed certificate..."

  openssl req -x509 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -days 365 \
    -nodes \
    -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:10.0.2.2"

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
fi

echo "Copying certificate to Android raw resources..."

mkdir -p "$ANDROID_RAW_DIR"
cp "$CER_FILE" "$ANDROID_CERT_FILE"

echo "Copying certificate to iOS app bundle..."

mkdir -p "$IOS_APP_DIR"
cp "$CER_FILE" "$IOS_CERT_FILE"

SSL_PIN=$(openssl x509 -in "$CERT_FILE" -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64)

echo ""
echo "Android SSL pin:"
echo "SSL_PIN=sha256/$SSL_PIN"
echo ""
echo "Copy this value into:"
echo "  android/local.properties"
echo ""

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