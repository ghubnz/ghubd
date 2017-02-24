#/usr/bin/env bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout key.pem -out cert.pem
openssl x509 -in cert.pem -noout -fingerprint
