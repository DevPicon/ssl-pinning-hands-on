#!/bin/bash

set -euo pipefail

WORK_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORK_DIR"
}

trap cleanup EXIT

public_key_pin() {
  local cert_file="$1"

  openssl x509 -in "$cert_file" -pubkey -noout \
    | openssl pkey -pubin -outform der \
    | openssl dgst -sha256 -binary \
    | openssl enc -base64
}

certificate_hash() {
  local cert_file="$1"

  openssl x509 -in "$cert_file" -outform der \
    | openssl dgst -sha256 -binary \
    | openssl enc -base64
}

same_or_changed() {
  local left="$1"
  local right="$2"

  if [[ "$left" == "$right" ]]; then
    echo "same"
  else
    echo "changed"
  fi
}

echo "Generating temporary certificates in $WORK_DIR"
echo ""

openssl genrsa -out "$WORK_DIR/key-v1.pem" 2048 >/dev/null 2>&1

openssl req -x509 -new \
  -key "$WORK_DIR/key-v1.pem" \
  -out "$WORK_DIR/cert-v1.pem" \
  -days 365 \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:10.0.2.2" \
  >/dev/null 2>&1

openssl req -x509 -new \
  -key "$WORK_DIR/key-v1.pem" \
  -out "$WORK_DIR/cert-v2-same-key.pem" \
  -days 730 \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:10.0.2.2" \
  >/dev/null 2>&1

openssl genrsa -out "$WORK_DIR/key-v2.pem" 2048 >/dev/null 2>&1

openssl req -x509 -new \
  -key "$WORK_DIR/key-v2.pem" \
  -out "$WORK_DIR/cert-v3-new-key.pem" \
  -days 365 \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:10.0.2.2" \
  >/dev/null 2>&1

CERT_V1_HASH="$(certificate_hash "$WORK_DIR/cert-v1.pem")"
CERT_V2_HASH="$(certificate_hash "$WORK_DIR/cert-v2-same-key.pem")"
CERT_V3_HASH="$(certificate_hash "$WORK_DIR/cert-v3-new-key.pem")"

PIN_V1="$(public_key_pin "$WORK_DIR/cert-v1.pem")"
PIN_V2="$(public_key_pin "$WORK_DIR/cert-v2-same-key.pem")"
PIN_V3="$(public_key_pin "$WORK_DIR/cert-v3-new-key.pem")"

echo "Certificate hash comparison"
echo "  v1 certificate:        $CERT_V1_HASH"
echo "  v2 same key cert:      $CERT_V2_HASH ($(same_or_changed "$CERT_V1_HASH" "$CERT_V2_HASH"))"
echo "  v3 new key cert:       $CERT_V3_HASH ($(same_or_changed "$CERT_V1_HASH" "$CERT_V3_HASH"))"
echo ""

echo "Public key pin comparison"
echo "  v1 public key pin:     sha256/$PIN_V1"
echo "  v2 same key pin:       sha256/$PIN_V2 ($(same_or_changed "$PIN_V1" "$PIN_V2"))"
echo "  v3 new key pin:        sha256/$PIN_V3 ($(same_or_changed "$PIN_V1" "$PIN_V3"))"
echo ""

echo "Takeaway:"
echo "  Renewing/reissuing a certificate with the same key changes the certificate hash,"
echo "  but keeps the public key pin stable."
echo ""
echo "  Generating a new key changes the public key pin."

