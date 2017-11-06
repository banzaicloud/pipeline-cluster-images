#!/usr/bin/env bash
 
set -o nounset
set -o pipefail
set -o errexit
 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y \
    apt-transport-https \
    socat \
    ebtables \
    cloud-utils \
    cloud-init \
    cloud-initramfs-growroot \
    docker.io=1.12.6-0ubuntu1~16.04.1 \
    kubelet=1.7.5-00 \
    kubeadm=1.7.5-00 \
    kubernetes-cni=0.5.1-00 \
    sysstat \
    iotop \
    rsync \
    ngrep \
    tcpdump \
    atop \
    python-pip

# We don't want to upgrade them.
apt-mark hold kubeadm kubectl kubelet kubernetes-cni

apt-get upgrade -y
pip install --upgrade pip

systemctl enable docker
systemctl start docker

sudo pip install awscli

login="$(aws ecr get-login)"

${login}

# Check this list. :)
# kubectl get pods --all-namespaces -o jsonpath="{..image}" |\
# tr -s '[[:space:]]' '\n' |\
# sort |\
# uniq -c

images=(
  "gcr.io/google_containers/defaultbackend:1.3"
  "gcr.io/google_containers/etcd-amd64:${ETCD_RELEASE_TAG}"

  "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:${K8S_DNS_RELEASE_TAG}"
  "gcr.io/google_containers/k8s-dns-kube-dns-amd64:${K8S_DNS_RELEASE_TAG}"
  "gcr.io/google_containers/k8s-dns-sidecar-amd64:${K8S_DNS_RELEASE_TAG}"

  "gcr.io/google_containers/kube-apiserver-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-controller-manager-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-proxy-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-scheduler-amd64:${KUBERNETES_RELEASE_TAG}"
  "gcr.io/google_containers/kube-state-metrics:v0.5.0"
  "gcr.io/google_containers/pause-amd64:3.0"
  "gcr.io/kubernetes-helm/tiller:${HELM_RELEASE_TAG}"

  "jimmidyson/configmap-reload:v0.1"
  "nginx:1.8"

  "banzaicloud/pushgateway:${PUSHGATEWAY_RELEASE_TAG:-v0.3.1}"
  "prom/prometheus:${PROMETHEUS_RELEASE_TAG:-v1.7.1}"

  "banzaicloud/spark-driver:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-driver-py:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-executor:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-executor-py:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-init:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-resource-staging-server:${SPARK_RELEASE_TAG}"
  "banzaicloud/spark-shuffle:${SPARK_RELEASE_TAG}"
  "banzaicloud/zeppelin-server:${ZEPPELIN_RELEASE_TAG}"

  "weaveworks/weave-npc:${WEAVE_RELEASE_TAG}"
  "weaveworks/weave-kube:${WEAVE_RELEASE_TAG}"
)

for i in "${images[@]}" ; do docker pull "${i}" ; done

apt-get upgrade -y

#install helm
curl https://storage.googleapis.com/kubernetes-helm/helm-${HELM_RELEASE_TAG}-linux-amd64.tar.gz | tar xz --strip 1 -C /usr/bin/

# Helm Charts
mkdir /opt/helm
cd /opt/helm

helm init -c
helm repo add banzaicloud-stable http://kubernetes-charts.banzaicloud.com
helm repo update
helm repo list
helm fetch banzaicloud-stable/pipeline-cluster
tar -xvzf pipeline-cluster*
rm -rf /home/ubuntu/.helm

cd -

# Helm Charts end


# Install prometheus node_exporter
mkdir /opt/node_exporter
wget -qO- "https://github.com/prometheus/node_exporter/releases/download/v0.15.0/node_exporter-0.15.0.linux-amd64.tar.gz" | tar -xzvf - --strip-components=1 -C /opt/node_exporter/

cp /tmp/node_exporter.service /etc/systemd/system/node_exporter.service

systemctl enable node_exporter
systemctl start  node_exporter

## Cleanup packer SSH key and machine ID generated for this boot
rm /root/.ssh/authorized_keys
rm /home/ubuntu/.ssh/authorized_keys
rm /etc/machine-id
touch /etc/machine-id
