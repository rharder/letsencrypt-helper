#!/bin/sh

PREV=$(stat signed_chain.crt)

echo "Renewing cert with letsencrypt..."
python3 acme_tiny.py --account-key account.key --csr domain.csr --acme-dir htdocs/challenges/ > signed_chain.crt.tmp || exit

echo "Success.  Moving signed_chain.crt"
mv signed_chain.crt.tmp signed_chain.crt
# restart python server

echo "Restarting mapserver with new cert."
sudo service mapserver restart

NEW=$(stat signed_chain.crt)

#(echo "NEW FILE: signed_chain.crt"; echo "$NEW"; echo ""; echo "OLD FILE: signed_chain.crt"; echo "$PREV") | pbpush -t "MapServer cert renewed" -b -


# # Example line in your crontab (runs once per month)
# 0 0 1 * * /path/to/renew_cert.sh 2>> /var/log/acme_tiny.log
