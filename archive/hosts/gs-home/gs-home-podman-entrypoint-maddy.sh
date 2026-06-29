#!/bin/sh

LDAP_USER_PASSWORD=$(cat "$LDAP_USER_PASSWORD_FILE" | tr -d "\n")
export LDAP_USER_PASSWORD

mkdir -p /etc/maddy
_sed=$(env | sed -n 's/^\([a-zA-Z_][a-zA-Z0-9_]*\)=\(.*\)/s|${\1}|\2|g; s|$\1|\2|g/p')
sed "$_sed" /maddy.conf >/configuration.conf
exec /bin/maddy -config /configuration.conf run
