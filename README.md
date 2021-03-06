# kubernetes-cluster
使用 Vagrant + VirtualBox 构建 Kubernetes 多节点集群环境


集群由 3 个节点组成，每个节点分别运行 Kubernetes Master 和 Kubernetes Node。
etcd、flannel 和 docker-ce 使用 yum 包直接安装，etcd 由 3 个实例组成的静态集群。
Kubernetes 使用二进制包安装，组件进程通过 systemd 管理（service 文件及相关配置文件参考 kubernetes-1.5.2 yum 安装包）。
kube-apiserver 连接 etcd 集群，使用 Keepalived 配置 kube-apiserver 浮动 IP，kubelet、kube-proxy、kube-controller-manager、kube-scheduler 通过浮动 IP 连接 kube-apiserver。
kubectl 通过浮动 IP 访问 kube-apiserver 操作 Kubernetes 集群。


### 环境信息

- macOS High Sierra
- Virtualbox 5.2.6 r120293
- Vagrant 2.0.2
- centos/7 1801.02


### 相关软件版本

- etcd 3.2.11+
- flannel 0.7.1+
- docker-ce 17.12.0-ce+
- Kubernetes 1.10.0+


## Addons

### 1. Dashboard

___参考资料___

[Web UI (Dashboard)](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

[Kubernetes Recommended setup](https://github.com/kubernetes/dashboard/wiki/Installation#recommended-setup)

### ~~2. Kube-DNS~~ _(Deprecated)_

___参考资料___

[kubernetes/cluster/addons/dns/kube-dns/](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns/kube-dns)

### 3. CoreDNS

___参考资料___

[CoreDNS for Kubernetes Service Discovery](https://coredns.io/2016/11/08/coredns-for-kubernetes-service-discovery/)

[CoreDNS for Kubernetes Service Discovery, Take 2](https://coredns.io/2017/03/01/coredns-for-kubernetes-service-discovery-take-2/)

[Custom DNS Entries For Kubernetes](https://coredns.io/2017/05/08/custom-dns-entries-for-kubernetes/)

[coredns/deployment/kubernetes](https://github.com/coredns/deployment/tree/master/kubernetes)

[kubernetes/kubernetes](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns/coredns)

### ~~4. Heapster + InfluxDB + Grafana~~ _(Deprecated)_

#### 1) Heapster

Heapster 提供 RESTful API 接口用于查询汇聚的性能数据，默认缓存最近 15 分钟的数据。

```
curl -u "admin:admin" -k https://172.17.0.100:6443/api/v1/proxy/namespaces/kube-system/services/heapster\
/api/v1/model/namespaces/kube-system/metrics/memory/usage
```

#### 2) Grafana

通过 Kubernetes Proxy API 访问 Grafana UI

```
https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy/
```

___注意问题___

Grafana 的 GF_SERVER_ROOT_URL 参数需要与[服务访问方式](#访问服务的方式以-kubernetes-dashboard-为例)保持一致，否则页面跳转可能会出错。

___参考资料___

[Resource Usage Monitoring in Kubernetes](https://kubernetes.io/blog/2015/05/resource-usage-monitoring-kubernetes/)

[kubernetes/heapster](https://github.com/kubernetes/heapster/tree/master/deploy/kube-config)

[kubernetes/kubernetes](https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/cluster-monitoring)

### 5. Metrics Server _(替代 Heapster)_

提供 `kubectl top node/top` 所需的指标数据。

___注意问题___

[Error: cluster doesn't provide requestheader-client-ca-file](https://github.com/kubernetes-incubator/kubespray/issues/2092)

___参考资料___

[Core metrics pipeline](https://kubernetes.io/docs/tasks/debug-application-cluster/core-metrics-pipeline/)

	Note: The API requires metrics server to be deployed in the cluster. Otherwise it will be not available.

[Metrics Server Design Doc](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/metrics-server.md).

### 6. kube-state-metrics

___参考资料___

[kubernetes/kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)

### 7. Prometheus

#### 1) Node-Exporter

#### 2) Blackbox-Exporter

#### 3) Prometheus

#### 4) Alertmanager

#### 5) Grafana


#### 监控内容
Prometheus 监控包括 _采集指标（白盒监控）_ 和 _探测服务(黑盒监控)_。
基于 Kubernetes 资源的监控似乎比较复杂，目前做了一些约定，详见[这里](/addons/prometheus/monitor_convention.md)。

##### 采集指标

1. job: prometheus -- 使用 static_configs

	* prometheus

2. job: kubernetes-apiserver  --  使用 <kubernetes_sd_configs> role: endpoints

	* kube-apiserver

3. job: kubernetes-node  --  使用 <kubernetes_sd_configs> role: node

	* node 节点

4. job: kubernetes-endpoints  --  使用 <kubernetes_sd_configs> role: endpoints

	* metrics-server

	* blackbox-exporter

	* kube-state-metrics

	* kube-dns（端口 9153）

	* kubernetes-dashboard

	* node-exporter

5. job: kubernetes-pod  --  使用 <kubernetes_sd_configs> role: pod

	* 暂无

##### 探测服务（通过 blackbox-exporter）

1. job: kubernetes-service-dns

	* kube-dns （udp 53）

2. job: kubernetes-service-http

	* kube-state-metrics （http）

	* kubernetes-dashboard （https）

	* metrics-server （https)


---

## 操作步骤

#### 1. 下载 Kubernetes 二进制包放到当前目录

[kubernetes-client-linux-amd64.tar.gz](https://dl.k8s.io/v1.9.2/kubernetes-client-linux-amd64.tar.gz)

[kubernetes-server-linux-amd64.tar.gz](https://dl.k8s.io/v1.9.2/kubernetes-server-linux-amd64.tar.gz)

#### 2. 启动虚拟机 （第一次启动过程需要执行软件安装，时间比较长，另外可能需要翻墙才能下载相关安装包和镜像）

```
vagrant up
```

#### 3. 登陆 vagrant 虚拟机（以 node-01 为例）

```
vagrant ssh node-01
```

#### 4. 使用 kubectl 操作 Kubernetes 集群

使用 CA 认证：
```
kubectl --server=https://127.0.0.1:6443 --certificate-authority=/etc/kubernetes/ssl/ca.crt \
--client-certificate=/etc/kubernetes/ssl/kubectl.crt \
--client-key=/etc/kubernetes/ssl/kubectl.key get node
```

使用用户名和口令认证：
```
kubectl --server=https://127.0.0.1:6443 --certificate-authority=/etc/kubernetes/ssl/ca.crt \
--username=admin --password=admin get node
```

#### 5. 调用 Kubernetes API 访问集群（使用 HTTP Basic 认证）

```
curl --cacert /etc/kubernetes/ssl/ca.crt -u "admin:admin" https://127.0.0.1:6443/version
```

---

## 多种方式访问集群中的服务（以 Kubernetes Dashboard 为例）<div id="Access"></div>

#### 1. ClusterIP （只能在集群节点上）

```
https://<ClusterIP>:443
```

#### 2. NodePort

```
https://127.0.0.1:30443
```

#### 3. Kubernetes Proxy API

```
https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy
```

#### 4. kubectl proxy

```
http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```
