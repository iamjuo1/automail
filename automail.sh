#!/bin/sh

set -u
source .env

addgroup mail
adduser $MAIL_USER -G mail

# CERT
acme.sh --issue --dns dns_cf -d $MAIL_DOMAIN

# MDA

cp dovecot.conf /etc/dovecot/dovecot.conf
rc-service dovecot start

# DKIM
mkdir /etc/dkim
openssl genpkey -algorithm ed25519             -out /etc/dkim/ed25519.key
openssl pkey -in /etc/dkim/ed25519.key -pubout -out /etc/dkim/ed25519.pub
chown rspamd /etc/dkim/ed25519.key
cat          /etc/dkim/ed25519.pub

# Spam filter
cp dkim_signing.conf /etc/rspamd/local.d/dkim_signing.conf
rc-service rspamd start

# MTA

# echo "$MAIL_USER $PASS_HASH" > /etc/smtpd/passwds
# echo "$DOMAIN"               > /etc/smtpd/mailname
#
# {
# echo "table aliases '/etc/smtpd/aliases'"
# echo "table passwds '/etc/smtpd/passwds'"
#
# echo "pki $MAIL_DOAMIN cert '/etc/letsencrypt/live/$MAIL_DOMAIN/fullchain.pem'"
# echo "pki $MAIL_DOAMIN key  '/etc/letsencrypt/live/$MAIL_DOMAIN/privkey.pem'"
