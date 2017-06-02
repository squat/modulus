# modulus
Automatically compile kernel modules for CoreOS Container Linux.

[![Build Status](https://semaphoreci.com/api/v1/squat/modulus/branches/master/shields_badge.svg)](https://semaphoreci.com/squat/modulus)

## Background
Compiling drivers on Container Linux is typically non-trivial because the OS ships without build tools and no obvious way to access the kernel sources. Modulus works by compiling your kernel modules inside of a Container Linux developer container as documented in [[1](https://github.com/coreos/docs/blob/master/os/kernel-modules.md)] and used in [[2](https://github.com/Clarifai/coreos-nvidia)]. Furthermore, because Container Linux updates automatically to keep your machine secure, your kernel modules can easily become out of date. Modulus automatically compiles kernel modules for the new version of Container Linux when your OS is upgrading so that the new modules are available when your machine restarts. Modulus is primarily a systemd template unit that can be coupled with any script that compiles kernel modules. This project currently includes a script for generating Nvidia drivers, however it can be extended to support any driver.

[1] https://github.com/coreos/docs/blob/master/os/kernel-modules.md

[2] https://github.com/Clarifai/coreos-nvidia

## Installation
```sh
sudo git clone https://github.com/squat/modulus.git /opt/modulus
sudo cp /opt/modulus/modulus@.service /etc/systemd/system/modulus@.service
```

## Compiling Nvidia Kernel Modules
Modulus makes it easy to automatically compile kernel modules for nvidia GPUs. Checkout the [nvidia README](https://github.com/squat/modulus/blob/master/nvidia/README.md) for detailed instructions.

## Distribution
After compiliation, Modulus installs all the compiled assets and places a copy in `/opt/modulus/archive/<driver-name>/<driver-version>`. Modulus also automatically tries to upload your compiled kernel modules to S3 so that you can compile the drivers once and reuse them across multiple machines. To enable this functionality, create a file named `.env` in your modulus directory, which defaults to `/opt/modulus`:

```
AWS_ACCESS_KEY_ID=<your-aws-access-key-id>
AWS_SECRET_ACCESS_KEY=<your-aws-secret-access-key>
MODULUS_S3_BUCKET=s3://your.s3/bucket-name/
```
