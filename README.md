# C-SCALE tutorial: Infrastructure as Code

The goal of this tutorial is to show a minimal example of
[Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code)
using [terraform](https://developer.hashicorp.com/terraform/tutorials).

# Slides

Check [these slides](https://docs.google.com/presentation/d/1KuYb1GgF_hGtocmL5-HvVvUonWUXJ9FF/edit?usp=sharing&ouid=100270527654140509265&rtpof=true&sd=true)
for more background about the tutorial.

# Jump into it!

Assuming you have:
1. Access to an OpenStack cloud
2. Installed and configured the software dependencies (see below)

With this tutorial we simply want to create a Virtual Machine (VM)
with:
* 8 vCPU cores
* 16 GB RAM
* Ubuntu 20.04
* Port 22 open so we can connect via SSH

Here is what you need to run this tutorial

```bash
# get a copy of this repository
cd working/dir/
git clone https://github.com/c-scale-community/c-scale-tutorial-iac.git
cd c-scale-tutorial-iac/terraform/

# initialize terraform
terraform init

# check what you are going to do
terraform plan

# apply changes (i.e. create a VM in OpenStack)
terraform apply
```

# One-off installation and configuration of the software environment

## Create an EGI Check-in account

Follow the steps [here](https://docs.egi.eu/users/check-in/signup/).

## Enroll a Virtual Organisation (VO)

Ask [C-SCALE support](https://helpdesk.c-scale.eu/) which VO you should enroll.
We have the
[eval.c-scale.eu](https://operations-portal.egi.eu/vo/view/voname/eval.c-scale.eu)
VO as a pilot. To request access you need to visit the
[enrollment URL](https://perun.egi.eu/egi/registrar/?vo=eval.c-scale.eu)
with your EGI Check-in account.

## Create an oidc-agent account

First, install [oidc-agent](https://indigo-dc.gitbook.io/oidc-agent/installation)
and configure it for [EGI Check-in](https://indigo-dc.gitbook.io/oidc-agent/user/oidc-gen/provider/egi).
With this you will configure a `<oidc-account>` that will be used below.

## Install and configure terraform and udocker

See steps below:

```bash
# install conda
cd working/dir/
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p conda-install
source conda-install/etc/profile.d/conda.sh
conda install mamba --channel conda-forge --yes
mamba create -n c-scale -c conda-forge terraform udocker --yes
conda activate c-scale

# configure udocker with fedcloudclient
# see https://indigo-dc.github.io/udocker/user_manual.html 
udocker pull tdviet/fedcloudclient:1.3.1
udocker create --name=fedcloudclient131 tdviet/fedcloudclient:1.3.1
udocker run fedcloudclient131 fedcloud --version
```

## Get access to OpenStack for terraform

See steps below:

```bash
# configure oidc-agent with your account
export OIDC_AGENT_ACCOUNT=<oidc-account>
export OIDC_ACCESS_TOKEN=$(oidc-token ${OIDC_AGENT_ACCOUNT})

# get <project-id> from OpenStack
udocker run --nobanner --hostenv fedcloudclient131 fedcloud endpoint projects --site <site>

# get <os-token> from OpenStack
udocker run --nobanner --hostenv fedcloudclient131 fedcloud endpoint env --site <site> --project-id <project-id>
udocker run --nobanner --hostenv fedcloudclient131 fedcloud openstack --vo <vo> --site <site> token issue -c id -f value
export OS_TOKEN=<os-token>
```

## Create Virtual Machine with terraform

Make sure your working directory is the [terraform folder](./terraform)
and follow the steps below:

```bash
terraform init
terraform plan
terraform apply
```

# Reusing the software environment

## Activate conda environment

If you have already completed the steps above, here is how to reuse
the software environment:

```bash
# reuse conda installation
cd working/dir/
source conda-install/etc/profile.d/conda.sh
conda activate c-scale
```

## Refreshing tokens

Tokens expire after a certain time. Here is how you can refresh them:

```bash
export OIDC_ACCESS_TOKEN=$(oidc-token ${OIDC_AGENT_ACCOUNT})
udocker run --nobanner --hostenv fedcloudclient131 fedcloud openstack --vo <vo> --site <site> token issue -c id -f value
export OS_TOKEN=<os-token>
```

## Terraform updates

If you change the terraform config, here is how to sync it with
the cloud configuration:

```bash
terraform plan
terraform apply
```
