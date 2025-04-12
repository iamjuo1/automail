.PHONY: require mail restart
.DEFAULT_GOAL = man

include .env

.env:
	cp .example.env .env

man:
	less Makefile README

require:
	apk add       \
		acme.sh   \
		rspamd    \
		dovecot   \
		opensmtpd \
		opensmtpd-filter-rspamd

mail:
	./automail.sh

restart:
	rc-service rspamd  restart
	rc-service smtpd   restart
	rc-service dovecot restart
