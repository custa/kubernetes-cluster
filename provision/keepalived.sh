#!/bin/bash
export PS4='+[${LINENO}:${FUNCNAME[0]}:$(basename "${BASH_SOURCE[0]}")] '
LOCATION_PATH="$( cd $(dirname ${BASH_SOURCE[0]}); pwd )"

# if ${SHELLOPTS} include "xtrace"
[[ "${SHELLOPTS}" =~ "xtrace" ]] && setx="-x" || setx="+x"
unsetx="+x"
# uncomment the next line to print all commands as they are executed.
#setx="-x"; unsetx="${setx}"

yum -y install keepalived

mkdir -p /etc/keepalived
cp -an /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.cyp
cp ${LOCATION_PATH}/etc/keepalived/keepalived.conf /etc/keepalived/
sed -i "s|After=.*|& kube-apiserver.service|" /usr/lib/systemd/system/keepalived.service

systemctl daemon-reload
systemctl enable keepalived
