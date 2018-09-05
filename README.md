# modulus
Automatically compile kernel modules for CoreOS Container Linux.

[![Build Status](https://semaphoreci.com/api/v1/squat/modulus/branches/master/shields_badge.svg)](https://semaphoreci.com/squat/modulus)

## Installation
To deploy Modulus to a Kubernetes cluster to install and maintain NVIDIA GPU drivers, run:
```sh
kubectl apply -f https://raw.githubusercontent.com/squat/modulus/master/nvidia/daemonset.yaml
```

## Background
Compiling drivers on Container Linux is typically non-trivial because the OS ships without build tools and no obvious way to access the kernel sources.
Modulus works by compiling your kernel modules inside of a Container Linux developer container as documented in [[1](https://github.com/coreos/docs/blob/master/os/kernel-modules.md)] and used in [[2](https://github.com/Clarifai/coreos-nvidia)].
Furthermore, because Container Linux updates automatically to keep your machine secure, your kernel modules can easily become out of date.
Modulus automatically compiles kernel modules for the new version of Container Linux when your OS is upgrading so that the new modules are available when your machine restarts.
Modulus can be used as a Kubernetes daemonset to maintain worker nodes up to date or as a systemd template unit and can be coupled with any script that compiles kernel modules.
This project currently supports generating NVIDIA and WireGuard kernel modules, however it can be extended to support any module.

[1] https://github.com/coreos/docs/blob/master/os/kernel-modules.md

[2] https://github.com/Clarifai/coreos-nvidia

## Compiling NVIDIA Kernel Modules
Modulus makes it easy to automatically compile kernel modules for NVIDIA GPUs. See the [NVIDIA README](https://github.com/squat/modulus/blob/master/nvidia/README.md) for detailed instructions.

## Compiling WireGuard Kernel Modules
See the [WireGuard README](https://github.com/squat/modulus/blob/master/wireguard/README.md) for detailed instructions.

## Distribution
After compiliation, Modulus installs all the compiled assets and caches them on disk. Modulus also automatically tries to upload your compiled kernel modules to S3 so that you can compile the drivers once and reuse them across multiple machines. To enable this functionality, provide the following environment variables to the Modulus daemonset:

```
AWS_ACCESS_KEY_ID=<your-aws-access-key-id>
AWS_SECRET_ACCESS_KEY=<your-aws-secret-access-key>
MODULUS_S3_BUCKET=s3://your.s3/bucket-name/
```

## Systemd Installation
Modulus can also be used as a set of Systemd services without depending on Kubernetes:
```sh
sudo git clone https://github.com/squat/modulus.git /opt/modulus
sudo cp /opt/modulus/modulus@.service /etc/systemd/system/modulus@.service
```
