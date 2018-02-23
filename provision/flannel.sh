#!/bin/bash
export PS4='+[${LINENO}:${FUNCNAME[0]}:$(basename "${BASH_SOURCE[0]}")] '
LOCATION_PATH="$( cd $(dirname ${BASH_SOURCE[0]}); pwd )"

# if ${SHELLOPTS} include "xtrace"
[[ "${SHELLOPTS}" =~ "xtrace" ]] && setx="-x" || setx="+x"
unsetx="+x"
# uncomment the next line to print all commands as they are executed.
#setx="-x"; unsetx="${setx}"

yum -y install flannel

sed -i "/^FLANNEL_OPTIONS=/d" /etc/sysconfig/flanneld
cat >>/etc/sysconfig/flanneld <<\EOF
FLANNEL_OPTIONS="-iface=eth1"
EOF
mkdir -p /etc/systemd/system/flanneld.service.d
cat > /etc/systemd/system/flanneld.service.d/network-config.conf <<\EOF
[Service]
#
TimeoutStartSec=300s
ExecStartPre=-/usr/bin/etcdctl set /atomic.io/network/config '{ "Network": "10.1.0.0/16" }'
EOF

systemctl daemon-reload
systemctl enable flanneld
