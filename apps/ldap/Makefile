DIR=openldap-2.4.33
PRECMD=(
EXE=slapd
ARGS=-s0 -f tsan1/$(DIR)/obj/tests/testrun/slapd.1.conf -h ldap://localhost:9011/ -d stats &)
POSTCMD=&& sleep 10 && /usr/bin/time -p ./tsan1/slapd-mtread -H ldap://localhost:9011/ -D cn=Manager,dc=example,dc=com -w secret -e cn=Monitor -c 4 -m 4 -L 100 -l 50 && killall -9 slapd &>/dev/null && killall -9 tsan-amd64-linux &>/dev/null
include ../Default.mk
