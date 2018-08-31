## Kubernetes 资源定义及 <kubernetes_sd_config> 配置之间的约定

1. 资源定义 Annotations

	* Service 的 annotations 作用于 role: service 和 role: endpoints
	* Pod 的 annotations 作用于 role: pod
	* 如果 scheme 非 http，配置 `prometheus.io/scheme: "https"`
	* 如果采集端口与提供服务端口不同，配置 `prometheus.io/port: "9153"`
	* 如果采集/探测路径不是默认路径（_/metrics_），配置 `prometheus.io/path: "/probe"`


2. <kubernetes_sd_config> 不同 role 配置

	* node
	
		- 通过 Kubernetes Proxy API 访问，避免防火墙等原因 Prometheus 无法直接连接 node

	* service
	
		- 通过 blackbox-exporter 对服务进行黑盒探测，不采集指标
		- `__meta_kubernetes_service_annotation_prometheus_io_probe` 明确指定是否探测
		- `__meta_kubernetes_service_annotation_prometheus_io_module` 指定 blackbox-exporter 的 module（blackbox-exporter 配置文件）

	* endpoints
	
		- 仅采集 endpoint 暴露端口的 target（ `__meta_kubernetes_endpoint_ready` 非空）
		- 根据 `__meta_kubernetes_service_annotation_prometheus_io_scrape` 判断是否采集 -- ___可选___

	* pod
	
		- 不采集无声明端口容器 target（`__meta_kubernetes_pod_container_port_number` 非空）
		- 根据 `__meta_kubernetes_pod_annotation_prometheus_io_scrape` 判断是否采集 -- ___可选___

	* ingress
	
		- <待补充>
