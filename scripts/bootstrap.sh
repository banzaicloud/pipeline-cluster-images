#!/usr/bin/env bash
 
set -o nounset
set -o pipefail
set -o errexit

export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb https://download.docker.com/linux/ubuntu xenial stable" > /etc/apt/sources.list.d/docker-ce.list

apt-get update -y
apt-get install -y \
    apt-transport-https \
    socat \
    ebtables \
    cloud-utils \
    cloud-init \
    cloud-initramfs-growroot \
    docker-ce=17.12.1~ce-0~ubuntu \
    kubelet="${KUBERNETES_VERSION}-00" \
    kubeadm="${KUBERNETES_VERSION}-00" \
    kubernetes-cni=0.6.0-00 \
    sysstat \
    iotop \
    rsync \
    ngrep \
    tcpdump \
    atop \
    python-pip \
    jq

# We don't want to upgrade them.
apt-mark hold kubeadm kubectl kubelet kubernetes-cni docker-ce

systemctl enable docker
systemctl start docker

apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes 

# Check this list. :)
# kubectl get pods --all-namespaces -o jsonpath="{..image}" |\
# tr -s '[[:space:]]' '\n' |\
# sort |\
# uniq -c

images=(
  "banzaicloud/spark-driver:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-driver-py:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-executor:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-executor-py:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-init:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-resource-staging-server:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-shuffle:${SPARK_RELEASE_TAG}"
  "banzaicloud/zeppelin-server:${ZEPPELIN_RELEASE_TAG}"

  "gcr.io/google_containers/etcd-amd64:${ETCD_RELEASE_TAG}"

  "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:${K8S_DNS_RELEASE_TAG}"
  "gcr.io/google_containers/k8s-dns-kube-dns-amd64:${K8S_DNS_RELEASE_TAG}"
  "gcr.io/google_containers/k8s-dns-sidecar-amd64:${K8S_DNS_RELEASE_TAG}"

  "gcr.io/google_containers/kube-apiserver-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-controller-manager-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-proxy-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-scheduler-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-state-metrics:v1.3.1"
  "gcr.io/google_containers/pause-amd64:3.1"
  "gcr.io/kubernetes-helm/tiller:${HELM_RELEASE_TAG}"

  "banzaicloud/pushgateway:${PUSHGATEWAY_RELEASE_TAG}"
  "prom/prometheus:${PROMETHEUS_RELEASE_TAG}"
  "jimmidyson/configmap-reload:v0.1"

  "traefik:${TRAEFIK_RELEASE_TAG}"
  "weaveworks/weave-npc:${WEAVE_RELEASE_TAG}"
  "weaveworks/weave-kube:${WEAVE_RELEASE_TAG}"
)

for i in "${images[@]}" ; do docker pull "${i}" ; done

#enable legacy interface name 
sed -i 's@GRUB_CMDLINE_LINUX=""@GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"@g' /etc/default/grub
update-grub

## Cleanup packer SSH key and machine ID generated for this boot
rm /root/.ssh/authorized_keys
rm /home/ubuntu/.ssh/authorized_keys
rm /etc/machine-id
rm -rf /var/lib/cloud/instances/*
touch /etc/machine-id
