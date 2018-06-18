
> 注意：
>
> 1. Windows（Git Bash）下 openssl req 需要对 “/” 转义，“/CN” 要改为 “//CN”
> 2. MAC（LibreSSL 2.2.7）下 openssl x509 -req 数字签名默认使用 sha1，因此需要明确指定 -sha256

### CA 密钥及证书
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout ca.key -out ca.crt -subj "/CN=ca.k8s.local"

### kube-apiserver、kube-controller-manager 及 kube-scheduler 密钥及证书
openssl req -nodes -newkey rsa:4096 -keyout master.key -out master.csr -subj "/CN=master.k8s.local"

openssl x509 -req -CAcreateserial -sha256 -CA ca.crt -CAkey ca.key -days 3650 -extensions v3_req -extfile master_ssl.cnf -in master.csr -out master.crt

### kube-proxy 及 kubelet 密钥及证书
openssl req -nodes -newkey rsa:4096 -keyout node.key -out node.csr -subj "/CN=node.k8s.local"

openssl x509 -req -CAcreateserial -sha256 -CA ca.crt -CAkey ca.key -days 3650 -extensions v3_req -extfile node_ssl.cnf -in node.csr -out node.crt

### kubectl 密钥及证书，指定 "/O=system:masters"，解决 kubectl 使用证书认证无权限创建 role 问题
openssl req -nodes -newkey rsa:4096 -keyout kubectl.key -out kubectl.csr -subj "/CN=kubectl.k8s.local/O=system:masters"

openssl x509 -req -CAcreateserial -sha256 -CA ca.crt -CAkey ca.key -days 3650 -extensions v3_req -extfile kubectl_ssl.cnf -in kubectl.csr -out kubectl.crt


### kubernetes-dashboard 密钥及证书
openssl req -nodes -newkey rsa:4096 -keyout dashboard/dashboard.key -out dashboard/dashboard.csr -subj "/CN=dashboard.k8s.local"

openssl x509 -req -CAcreateserial -sha256 -CA ca.crt -CAkey ca.key -days 3650 -extensions v3_req -extfile dashboard/dashboard_ssl.cnf -in dashboard/dashboard.csr -out dashboard/dashboard.crt


### Service Account 密钥对
openssl genrsa -out service-account.key 4096


### 查看证书的文本内容
openssl x509 -text -noout -in ca.crt

### 查看证书请求的文本内容
openssl req -text -noout -in kubectl.csr


### 参考资料
[The Most Common OpenSSL Commands](https://www.sslshopper.com/article-most-common-openssl-commands.html)
[openssl-req](https://www.openssl.org/docs/man1.0.2/apps/openssl-req.html)
[openssl-x509](https://www.openssl.org/docs/man1.0.2/apps/x509.html)

