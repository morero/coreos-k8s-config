ETCD_ENDPOINTS = http://coreos1:2379,http://coreos2:2379,http://coreos3:2379
MASTER_IP = 192.168.1.175
HYPERKUBE_VERSION = v1.3.6_coreos.0

cloud-config/coreos3-cloud-config.yaml: cloud-config-k8s-master.yaml
	cat "$<" \
	| sed -e 's#MYIPADDRESS#$(MASTER_IP)#' \
	| sed -e 's#MYETCDENDPOINTS#$(ETCD_ENDPOINTS)#' \
	| sed -e 's#HYPERKUBE_VERSION#$(HYPERKUBE_VERSION)#' > "$@"

cloud-config/coreos0-cloud-config.yaml: cloud-config-k8s-worker.yaml
	cat "$<" \
	| sed -e 's#MYHOSTNAME#coreos0#' \
	| sed -e 's#MYIPADDRESS#192.168.1.XXX#' \
	| sed -e 's#MYETCDENDPOINTS#$(ETCD_ENDPOINTS)#' \
	| sed -e 's#HYPERKUBE_VERSION#$(HYPERKUBE_VERSION)#' \
	| sed -e 's#MASTER_IP#$(MASTER_IP)#' > "$@"

cloud-config/coreos1-cloud-config.yaml: cloud-config-k8s-worker.yaml
	cat "$<" \
	| sed -e 's#MYHOSTNAME#coreos1#' \
	| sed -e 's#MYIPADDRESS#192.168.1.196#' \
	| sed -e 's#MYETCDENDPOINTS#$(ETCD_ENDPOINTS)#' \
	| sed -e 's#HYPERKUBE_VERSION#$(HYPERKUBE_VERSION)#' \
	| sed -e 's#MASTER_IP#$(MASTER_IP)#' > "$@"

cloud-config/coreos2-cloud-config.yaml: cloud-config-k8s-worker.yaml
	cat "$<" \
	| sed -e 's#MYHOSTNAME#coreos2#' \
	| sed -e 's#MYIPADDRESS#192.168.1.182#' \
	| sed -e 's#MYETCDENDPOINTS#$(ETCD_ENDPOINTS)#' \
	| sed -e 's#HYPERKUBE_VERSION#$(HYPERKUBE_VERSION)#' \
	| sed -e 's#MASTER_IP#$(MASTER_IP)#' > "$@"

cloud-config/coreos4-cloud-config.yaml: cloud-config-k8s-worker.yaml
	cat "$<" \
	| sed -e 's#MYHOSTNAME#coreos4#' \
	| sed -e 's#MYIPADDRESS#192.168.1.XXX#' \
	| sed -e 's#MYETCDENDPOINTS#$(ETCD_ENDPOINTS)#' \
	| sed -e 's#HYPERKUBE_VERSION#$(HYPERKUBE_VERSION)#' \
	| sed -e 's#MASTER_IP#$(MASTER_IP)#' > "$@"

k8s-keys/%-key.pem:
	openssl genrsa -out "$@" 2048

k8s-keys/ca.pem: k8s-keys/ca-key.pem
	openssl req -x509 -new -nodes -key "$<" -days 10000 -out "$@" -subj "/CN=kube-ca"

k8s-keys/apiserver.csr: k8s-keys/apiserver-key.pem openssl.cnf
	openssl req -new -key k8s-keys/apiserver-key.pem -out "$@" -subj "/CN=kube-apiserver" -config openssl.cnf

k8s-keys/coreos0-worker.csr: k8s-keys/coreos0-worker-key.pem worker-openssl.cnf
	WORKER_FQDN=coreos0 WORKER_IP=192.168.1.100 openssl req -new -key k8s-keys/coreos0-worker-key.pem -out "$@" -subj "/CN=coreos0" -config worker-openssl.cnf

k8s-keys/coreos0-worker.pem: k8s-keys/coreos0-worker.csr k8s-keys/ca.pem \
                             k8s-keys/ca-key.pem worker-openssl.cnf
	WORKER_FQDN=coreos0 WORKER_IP=192.168.1.100 openssl x509 -req -in k8s-keys/coreos0-worker.csr -CA k8s-keys/ca.pem -CAkey k8s-keys/ca-key.pem -CAcreateserial -out "$@" -days 365 -extensions v3_req -extfile worker-openssl.cnf

k8s-keys/coreos1-worker.csr: k8s-keys/coreos1-worker-key.pem worker-openssl.cnf
	WORKER_FQDN=coreos1 WORKER_IP=192.168.1.196 openssl req -new -key k8s-keys/coreos1-worker-key.pem -out "$@" -subj "/CN=coreos1" -config worker-openssl.cnf

k8s-keys/coreos1-worker.pem: k8s-keys/coreos1-worker.csr k8s-keys/ca.pem \
                             k8s-keys/ca-key.pem worker-openssl.cnf
	WORKER_FQDN=coreos1 WORKER_IP=192.168.1.196 openssl x509 -req -in k8s-keys/coreos1-worker.csr -CA k8s-keys/ca.pem -CAkey k8s-keys/ca-key.pem -CAcreateserial -out "$@" -days 365 -extensions v3_req -extfile worker-openssl.cnf

k8s-keys/coreos2-worker.csr: k8s-keys/coreos2-worker-key.pem worker-openssl.cnf
	WORKER_FQDN=coreos2 WORKER_IP=192.168.1.182 openssl req -new -key k8s-keys/coreos2-worker-key.pem -out "$@" -subj "/CN=coreos2" -config worker-openssl.cnf

k8s-keys/coreos2-worker.pem: k8s-keys/coreos2-worker.csr k8s-keys/ca.pem \
                             k8s-keys/ca-key.pem worker-openssl.cnf
	WORKER_FQDN=coreos2 WORKER_IP=192.168.1.182 openssl x509 -req -in k8s-keys/coreos2-worker.csr -CA k8s-keys/ca.pem -CAkey k8s-keys/ca-key.pem -CAcreateserial -out "$@" -days 365 -extensions v3_req -extfile worker-openssl.cnf

k8s-keys/apiserver.pem: k8s-keys/apiserver.csr k8s-keys/ca.pem \
                        k8s-keys/ca-key.pem openssl.cnf
	openssl x509 -req -in k8s-keys/apiserver.csr -CA k8s-keys/ca.pem -CAkey k8s-keys/ca-key.pem -CAcreateserial -out "$@" -days 365 -extensions v3_req -extfile openssl.cnf

k8s-keys/admin.csr: k8s-keys/admin-key.pem
	openssl req -new -key k8s-keys/admin-key.pem -out "$@" -subj "/CN=kube-admin"

k8s-keys/admin.pem: k8s-keys/admin.csr k8s-keys/ca.pem k8s-keys/ca-key.pem
	openssl x509 -req -in k8s-keys/admin.csr -CA k8s-keys/ca.pem -CAkey k8s-keys/ca-key.pem -CAcreateserial -out "$@" -days 365

keys: k8s-keys/apiserver.pem k8s-keys/admin.pem k8s-keys/coreos0-worker.pem \
      k8s-keys/coreos1-worker.pem k8s-keys/coreos2-worker.pem

deploy-coreos1: cloud-config/coreos1-cloud-config.yaml keys
	scp cloud-config/coreos1-cloud-config.yaml k8s-keys/ca.pem k8s-keys/coreos1-*.pem coreos1:/home/core
	ssh coreos1 sudo mkdir -p /etc/kubernetes/ssl
	ssh coreos1 sudo mv ca.pem -t /etc/kubernetes/ssl
	ssh coreos1 sudo mv coreos1-worker.pem /etc/kubernetes/ssl/worker.pem
	ssh coreos1 sudo mv coreos1-worker-key.pem /etc/kubernetes/ssl/worker-key.pem
	ssh coreos1 sudo chmod 600 /etc/kubernetes/ssl/*-key.pem
	ssh coreos1 sudo chown root:root /etc/kubernetes/ssl/*-key.pem
	ssh coreos1 sudo mv coreos1-cloud-config.yaml /var/lib/coreos-install/user_data
	ssh coreos1 sudo coreos-cloudinit -from-file /var/lib/coreos-install/user_data

deploy-coreos2: cloud-config/coreos2-cloud-config.yaml keys
	scp cloud-config/coreos2-cloud-config.yaml k8s-keys/ca.pem k8s-keys/coreos2-*.pem coreos2:/home/core
	ssh coreos2 sudo mkdir -p /etc/kubernetes/ssl
	ssh coreos2 sudo mv ca.pem -t /etc/kubernetes/ssl
	ssh coreos2 sudo mv coreos2-worker.pem /etc/kubernetes/ssl/worker.pem
	ssh coreos2 sudo mv coreos2-worker-key.pem /etc/kubernetes/ssl/worker-key.pem
	ssh coreos2 sudo chmod 600 /etc/kubernetes/ssl/*-key.pem
	ssh coreos2 sudo chown root:root /etc/kubernetes/ssl/*-key.pem
	ssh coreos2 sudo mv coreos2-cloud-config.yaml /var/lib/coreos-install/user_data
	ssh coreos2 sudo coreos-cloudinit -from-file /var/lib/coreos-install/user_data

deploy-coreos3: cloud-config/coreos3-cloud-config.yaml keys
	scp cloud-config/coreos3-cloud-config.yaml k8s-keys/ca.pem k8s-keys/apiserver*.pem coreos3:/home/core
	ssh coreos3 sudo mkdir -p /etc/kubernetes/ssl
	ssh coreos3 sudo mv ca.pem apiserver*.pem -t /etc/kubernetes/ssl
	ssh coreos3 sudo chmod 600 /etc/kubernetes/ssl/*-key.pem
	ssh coreos3 sudo chown root:root /etc/kubernetes/ssl/*-key.pem
	ssh coreos3 sudo mv coreos3-cloud-config.yaml /var/lib/coreos-install/user_data
	ssh coreos3 sudo coreos-cloudinit -from-file /var/lib/coreos-install/user_data

deploy: deploy-coreos1 deploy-coreos2 deploy-coreos3