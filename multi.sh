#!/usr/bin/env bash
# Move to the directory where you want to have the keys
YOURSITES=DNS:sub1.domain.com,DNS:sub2.domain.com

git clone https://github.com/diafygi/acme-tiny.git

PREV_DIR=$(pwd)
WD=multi
rm -rf $WD
mkdir -p $WD
cd $WD
openssl genrsa 4096 > account.key
openssl genrsa 4096 > domain.key

# Single Domain:
#openssl req -new -sha256 -key domain.key -subj "/CN=${YOURSITE}" > domain.csr

# Multiplie Domains:
OPENSSLCNF=/etc/pki/tls/openssl.cnf
openssl req -new -sha256 -key domain.key -subj "/" -reqexts SAN -config <(cat $OPENSSLCNF <(printf "[SAN]\nsubjectAltName=${YOURSITES}")) > domain.csr



mkdir -p wwwtemp/.well-known/acme-challenge/
PIDFILE=$(mktemp)
function launchhttp(){
  cd wwwtemp
  sudo python3 -m http.server 80 &
  echo $! > $PIDFILE
  cd ..
}
launchhttp &

# Live LetsEncrypt server
python3 ../acme-tiny/acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir ./wwwtemp/.well-known/acme-challenge  > ./signed_chain.crt

# Development (untrusted) server
#python3 ../acme-tiny/acme_tiny.py --directory-url "https://acme-staging-v02.api.letsencrypt.org/directory" --account-key ./account.key --csr ./domain.csr --acme-dir ./wwwtemp/.well-known/acme-challenge  > ./signed_chain.crt

# Clean up
sudo kill $(cat $PIDFILE)
rm -rf wwwtemp
cd "$PREV_DIR"




