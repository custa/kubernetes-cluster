# kubernetes-cluster
使用 Vagrant + VirtualBox 构建 Kubernetes 多节点集群环境

集群由 3 个节点（虚拟机）组成，每个节点分别运行 Kubernetes Master 和 Kubernetes Node。
etcd、flannel 和 docker-ce 使用 yum 包直接安装，etcd 由 3 个实例组成的静态集群。
Kubernetes 使用二进制包安装，各个组件进程通过 systemd 管理（service 文件及相关配置文件参照 kubernetes-1.5.2 yum 安装包）。
kube-apiserver 进程通过连接 etcd 集群构成集群，kubelet、kube-proxy、kube-controller-manager、kube-scheduler 组件连接本节点上的 kube-apiserver（当前未配置负载均衡器）。
kubectl 通过本节点上的 kube-apiserver 访问 Kubernetes 集群。

### 环境信息：
- macOS High Sierra
- Virtualbox 5.2.6 r120293
- Vagrant 2.0.2
- centos/7 1801.02

### 相关软件版本：
- etcd 3.2.11
- flannel 0.7.1
- docker-ce 17.12.0-ce
- Kubernetes 1.9.2

### 使用步骤：
- 下载 Kubernetes 二进制包放到当前目录

[kubernetes-client-linux-amd64.tar.gz](https://dl.k8s.io/v1.9.2/kubernetes-client-linux-amd64.tar.gz)

[kubernetes-server-linux-amd64.tar.gz](https://dl.k8s.io/v1.9.2/kubernetes-server-linux-amd64.tar.gz)

- 启动虚拟机

> 第一次启动过程需要执行软件安装，时间比较长，可能需要翻墙才能下载相关安装包

```
vagrant up
```

- 登陆 node-01

```
vagrant ssh node-01
```

- 使用 kubectl 操作 Kubernetes 集群

```
kubectl --server=https://127.0.0.1:6443 --certificate-authority=/etc/kubernetes/ssl/ca.crt --client-certificate=/etc/kubernetes/ssl/kubectl.crt --client-key=/etc/kubernetes/ssl/kubectl.key get node
```
or
```
kubectl --server=https://127.0.0.1:6443 --certificate-authority=/etc/kubernetes/ssl/ca.crt --username=admin --password=admin get node
```
or
```
curl --cacert /etc/kubernetes/ssl/ca.crt -u "admin:admin" https://127.0.0.1:6443/version
```
