#!/bin/bash
export PS4='+[${LINENO}:${FUNCNAME[0]}:$(basename "${BASH_SOURCE[0]}")] '
LOCATION_PATH="$( cd $(dirname ${BASH_SOURCE[0]}); pwd )"

# if ${SHELLOPTS} include "xtrace"
[[ "${SHELLOPTS}" =~ "xtrace" ]] && setx="-x" || setx="+x"
unsetx="+x"
# uncomment the next line to print all commands as they are executed.
#setx="-x"; unsetx="${setx}"

KUBERNETES_VERSION="v1.9.2"

[[ -f /vagrant/kubernetes-server-linux-amd64.tar.gz ]] || \
  curl -sSL -o /vagrant/kubernetes-server-linux-amd64.tar.gz \
  https://dl.k8s.io/${KUBERNETES_VERSION}/kubernetes-server-linux-amd64.tar.gz
tar -zxf /vagrant/kubernetes-server-linux-amd64.tar.gz -C /vagrant

cp /vagrant/kubernetes/server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kube-proxy,kubelet,kubectl} /usr/bin/

mkdir -p /etc/kubernetes
cp -r ${LOCATION_PATH}/etc/kubernetes/* /etc/kubernetes/
sed -i "s|{{KUBE_ETCD_SERVERS}}|$2|" /etc/kubernetes/apiserver
sed -i "s|{{IP}}|$1|" /etc/kubernetes/kubelet

# kubelet 配置 WorkingDirectory=/var/lib/kubelet，需要手动创建该目录，不能在 ExecStartPre 创建
mkdir -p /var/lib/kubelet

cp ${LOCATION_PATH}/var/lib/kubelet/kubeconfig /var/lib/kubelet/

cp ${LOCATION_PATH}/usr/lib/systemd/system/* /usr/lib/systemd/system/

echo "source <(kubectl completion bash)" >> ~/.bashrc

systemctl daemon-reload
systemctl enable kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet
