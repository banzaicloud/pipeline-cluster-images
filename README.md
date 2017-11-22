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
```bash
cp .env.example .env

# Please fill empty vars
source .env

make build-aws-ubuntu-xenial
```

### Limitation/Known issue

Packer can't use [AWS_SPOT_PRICE](https://github.com/hashicorp/packer/issues/2763) with enhanced networking.

### Supported regions
```
eu-west-1
```

## Latest Image

* eu-west-1:  `ami-06d1667f`
