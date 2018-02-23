#!/bin/bash
export PS4='+[${LINENO}:${FUNCNAME[0]}:$(basename "${BASH_SOURCE[0]}")] '
LOCATION_PATH="$( cd $(dirname ${BASH_SOURCE[0]}); pwd )"

# if ${SHELLOPTS} include "xtrace"
[[ "${SHELLOPTS}" =~ "xtrace" ]] && setx="-x" || setx="+x"
unsetx="+x"
# uncomment the next line to print all commands as they are executed.
#setx="-x"; unsetx="${setx}"

cp -an /etc/etcd/etcd.conf /etc/etcd/etcd.conf.cyp
sed -e "s|{{ETCD_NAME}}|$1|g" \
    -e "s|{{IP}}|$2|g" \
    -e "s|{{ETCD_INITIAL_CLUSTER}}|$3|g" \
    ${LOCATION_PATH}/etc/etcd/etcd.conf >/etc/etcd/etcd.conf
