# SSL Pinning Hands-on

Hands-on project to demonstrate SSL/TLS pinning in mobile apps.

This repository contains:

- A minimal Ktor backend running with HTTPS
- An Android client sample
- An iOS client sample
- Scripts to make the environment reproducible

## Project Structure

```text
ssl-pinning-hands-on/
├── backend/
│   ├── ktor-app/
│   ├── certs/
│   └── docker/
├── android/
├── ios/
├── scripts/
├── docker-compose.yml
└── README.md
```

## Goal

The goal is to show how mobile apps can validate a backend certificate or public key using SSL/TLS pinning.

This project is educational. The certificates used here are for local development only.

Do not use these certificates in production.

## What You Will Learn

- How to run a TLS-enabled backend locally  
- How SSL/TLS pinning works in practice  
- How to extract a public key pin  
- How mobile apps validate server identity  

## Requirements

- Docker
- Docker Compose
- curl
- Android Studio
- Xcode

## Running the backend

From the root of the project, run:

```
./scripts/setup.sh
```

The backend will be available at:

```
https://localhost:8443
```

For Android Emulator, use:

```
https://10.0.2.2:8443
```

## Available Endpoints

Health check:

```
 GET /health
```

Expected response:

```
 { “status”: “ok” }
```

Secure data:

```
 GET /secure-data
```

Expected response:

```
 { “data”: “This response comes from a TLS-enabled Ktor backend” }
```

## Testing with curl

Because this backend uses a self-signed certificate, use:

```
curl -k https://localhost:8443/health
```

## Certificates

This project generates local self-signed certificates for demonstration purposes.

During setup, the following files are created:

- `server.pem` → Server certificate
- `key.pem` → Private key
- `server.cer` → Certificate for iOS
- `keystore.p12` → Keystore used by Ktor

## Extracting the SHA-256 Pin (for Android)

To generate the public key pin used in Android:

```
openssl x509 -in backend/certs/server.pem -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
```

Use the output like this:

```bash
sha256/YOUR_BASE64_PIN
```

## First Run Validation

After running the setup script, validate the backend:
```bash
curl -k https://localhost:8443/health
```

Expected response:
```json
{ “status”: “ok” }
```


## Educational Notes

This backend exists to support SSL pinning demos.

It is intentionally simple:

- No authentication
- No database
- No API Gateway
- No production certificate authority

The focus is mobile SSL/TLS pinning, not backend architecture.

## Planned Clients

- Android app using OkHttp CertificatePinner
- iOS app using URLSession certificate pinning
- iOS app using public key pinning

## Quick Troubleshooting

- If port 8443 is already in use, stop the conflicting service or change the port in docker-compose.yml
- If Docker is not running, start it before executing the script
- If curl fails, try adding the -k flag to ignore certificate validation

