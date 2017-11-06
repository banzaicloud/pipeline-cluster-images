## K8S Image build

### List targets
```bash
make list
```

### Dry run
```bash
DRY_RUN=1 \
make build-aws-ubuntu-xenial
```

### Run with user environment
```
export AWS_REGION=eu-west-1
export AWS_DEFAULT_REGION=eu-west-1
export AWS_SSH_USERNAME=ubuntu
export AWS_SOURCE_AMI=ami-add175d4
export AWS_INTANCE_TYPE=c4.large
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

export KUBERNETES_RELEASE_TAG=v1.7.3
export ETCD_RELEASE_TAG=3.0.17
export K8S_DNS_RELEASE_TAG=1.14.4
export SPARK_RELEASE_TAG=v2.2.0-k8s-1.0.161
export ZEPPELIN_RELEASE_TAG=v2.2.0-k8s-1.0.34
export HELM_RELEASE_TAG=v2.6.0
export WEAVE_RELEASE_TAG=2.0.4
export PROMETHEUS_RELEASE_TAG=v1.7.1
export PUSHGATEWAY_RELEASE_TAG=v0.3.1

export BASE_NAME=pipeline-cluster-image

make build-aws-ubuntu-xenial
```

### Limitation/Known issue

Packer can't use [AWS_SPOT_PRICE](https://github.com/hashicorp/packer/issues/2763) with enhanced networking.

### Supported regions
```
eu-west-1
```

## Latest Image

* eu-west-1:  `ami-7a6ac803`
