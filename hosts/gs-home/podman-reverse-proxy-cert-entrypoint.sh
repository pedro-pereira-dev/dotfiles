#!/bin/sh
set -eou pipefail

DEBUG_OPTS='' && [ -n "$DEBUG" ] && DEBUG_OPTS=--staging

DOMAIN=${DOMAIN:-example.com}

SPACESHIP_API_KEY_FILE=${SPACESHIP_API_KEY_FILE:-''}
SPACESHIP_API_SECRET_FILE=${SPACESHIP_API_SECRET_FILE:-''}

[ -f "$SPACESHIP_API_KEY_FILE" ] && [ -f "$SPACESHIP_API_SECRET_FILE" ] ||
  { echo "Missing 'SPACESHIP_API_KEY_FILE' or 'SPACESHIP_API_SECRET_FILE'" && exit 1; }

SPACESHIP_API_KEY=$(cat "$SPACESHIP_API_KEY_FILE")
SPACESHIP_API_SECRET=$(cat "$SPACESHIP_API_SECRET_FILE")

[ -n "$SPACESHIP_API_KEY" ] && [ -n "$SPACESHIP_API_SECRET" ] ||
  { echo "Empty 'SPACESHIP_API_KEY' or 'SPACESHIP_API_SECRET'" && exit 1; }

export SPACESHIP_API_KEY SPACESHIP_API_SECRET
apk add --no-cache acme.sh
acme.sh $DEBUG_OPTS \
  --cert-home certs \
  --config-home /acme \
  --dns dns_spaceship \
  --issue \
  -d "$DOMAIN" \
  -d "*.$DOMAIN"

# [reverse_proxy_cert]         | [Tue Dec  9 22:34:49 UTC 2025] Registered
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:49 UTC 2025] ACCOUNT_THUMBPRINT='0jqiraRkq7pzm2WMAfp6LO5PSAcWolsbW_h1ZBdqjjM'
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:49 UTC 2025] Creating domain key
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:49 UTC 2025] The domain key is here: /root/.acme.sh/boarede.com_ecc/boarede.com.key
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:49 UTC 2025] Multi domain='DNS:boarede.com,DNS:*.boarede.com'
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:51 UTC 2025] Getting webroot for domain='boarede.com'
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:51 UTC 2025] Getting webroot for domain='*.boarede.com'
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:51 UTC 2025] Adding TXT value: STtrcyqPHRgPSMtRrcSYV9d0v5z-0ntgFNz1sQNt_w0 for domain: _acme-challenge.boarede.com
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:51 UTC 2025] Adding TXT record for _acme-challenge.boarede.com with value STtrcyqPHRgPSMtRrcSYV9d0v5z-0ntgFNz1sQNt_w0
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:52 UTC 2025] Root domain 'boarede.com' saved to configuration for future use.
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:52 UTC 2025] Successfully added TXT record for _acme-challenge.boarede.com
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:52 UTC 2025] The TXT record has been successfully added.
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:52 UTC 2025] Adding TXT value: 4ZPIiPNfns3tV9GSRmxe35_WNQ7CxUeGp74GZwEPotY for domain: _acme-challenge.boarede.com
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:52 UTC 2025] Adding TXT record for _acme-challenge.boarede.com with value 4ZPIiPNfns3tV9GSRmxe35_WNQ7CxUeGp74GZwEPotY
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:53 UTC 2025] Successfully added TXT record for _acme-challenge.boarede.com
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:53 UTC 2025] The TXT record has been successfully added.
# [reverse_proxy_cert]         | [Tue Dec  9 22:34:53 UTC 2025] Let's check each DNS record now. Sleeping for 20 seconds first.
# [reverse_proxy_cert]         | [Tue Dec  9 22:35:13 UTC 2025] You can use '--dnssleep' to disable public dns checks.
# [reverse_proxy_cert]         | [Tue Dec  9 22:35:13 UTC 2025] See: https://github.com/acmesh-official/acme.sh/wiki/dnscheck
# [reverse_proxy_cert]         | [Tue Dec  9 22:35:13 UTC 2025] Checking boarede.com for _acme-challenge.boarede.com
# [reverse_proxy_cert]         | [Tue Dec  9 22:35:13 UTC 2025] Not valid yet, let's wait for 10 seconds then check the next one.
# [reverse_proxy_cert]         | [Tue Dec  9 22:35:23 UTC 2025] Checking boarede.com for _acme-challenge.boarede.com
# [reverse_proxy_cert]         | [Tue Dec  9 22:35:24 UTC 2025] Success for domain boarede.com '_acme-challenge.boarede.com'.
# [reverse_proxy_cert]         | [Tue Dec  9 22:35:24 UTC 2025] Let's wait for 10 seconds and check again.

# [ ! -f "$_work_dir/certs/ssl.pem" ] && {
#   apk add --no-cache curl openssl
#   _fullchain=$(mktemp) && _privkey=$(mktemp)
#   mkdir -p "$_work_dir/certs"
#   openssl req -newkey rsa:2048 -nodes -x509 -keyout "$_privkey" -out "$_fullchain" -subj "/CN=$_domain"
#   cat "$_fullchain" "$_privkey" >"$_work_dir/certs/ssl.pem"
# }

# sleep 10
