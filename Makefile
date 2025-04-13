.PHONY: man mail require cert mda dkim spam mta restart
.DEFAULT_GOAL = man

PRK = /etc/dkim/ed25519.key
PBK = /etc/dkim/ed25519.pub

include .env

.env:
	cp .example.env .env

man:
	less Makefile

mail: require cert mda dkim spam mta

require:
	apk add       \
		acme.sh   \
		rspamd    \
		dovecot   \
		opensmtpd \
		opensmtpd-filter-rspamd
	adduser $(MAIL_USER) -G mail

cert:
	acme.sh --register-account -m $(MAIL)
	CF_Token=$(CF_Token) acme.sh --issue --dns dns_cf -d $(MAIL_SERVER)

mda:
	cp dovecot.conf /etc/dovecot/dovecot.conf
	rc-service dovecot restart || dovecot

dkim:
	mkdir -p /etc/dkim
	[ -e $(PRK) ] || openssl genpkey -algorithm ed25519 -out $(PRK)
	openssl pkey -in $(PRK) -pubout -out $(PBK)
	chown rspamd $(PRK)
	cat          $(PBK)

spam:
	cp dkim_signing.conf /etc/rspamd/local.d/dkim_signing.conf
	rc-service rspamd restart

mta:
	cp smtpd.conf /etc/smtpd/smtpd.conf
	rc-service smtpd restart || smtpd

restart:
	rc-service rspamd  restart
	rc-service smtpd   restart
	rc-service dovecot restart
