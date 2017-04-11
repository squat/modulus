# modulus
Automatically compile kernel modules for CoreOS Container Linux.

## Background
Compiling drivers on Container Linux is typically non-trivial because the OS ships without build tools and no obvious way to access the kernel sources. Modulus works by compiling your kernel modules inside of a Container Linux developer container as documented in [[1](https://github.com/coreos/docs/blob/master/os/kernel-modules.md)] and used in [[2](https://github.com/Clarifai/coreos-nvidia)]. Furthermore, because Container Linux updates automatically to keep your machine secure, your kernel modules can easily become out of date. Modulus automatically compiles kernel modules for the new version of Container Linux when your OS is upgrading so that the new modules are available when your machine restarts. Modulus is primarily a systemd template unit that can be coupled with any script that compiles kernel modules. This project currently includes a script for generating Nvidia drivers, however it can be extended to support any driver.

[1] https://github.com/coreos/docs/blob/master/os/kernel-modules.md

[2] https://github.com/Clarifai/coreos-nvidia

## Installation
```sh
git clone https://github.com/squat/modulus.git && cd modulus
sudo mkdir -p /opt/bin
sudo cp modulus /opt/bin/
sudo cp modulus@.service /etc/systemd/system/modulus@.service
```

## Compiling Nvidia Kernel Modules
Copy the `nvidia/compile` script to `/opt/bin` with the version of Nvidia that you want to compile as the filename:
```sh
sudo cp nvidia/compile /opt/bin/378.13
```

Enable the modulus service:
```sh
sudo systemctl enable modulus@378.13
sudo systemctl start modulus@378.13
```

## Distribution
After compiliation, modulus places your modules in `/home/core/.modulus/<driver-version>/out`. Modulus also automatically tries to upload your compiled kernel modules to S3 so that you can compile the drivers once and reuse them across multiple machines. To enable this functionality, create a file named `awsenv` in `/home/core` that looks like:

```
AWS_ACCESS_KEY_ID=<your-aws-access-key-id>
AWS_SECRET_ACCESS_KEY=<your-aws-secret-access-key>
S3_BUCKET=s3://your.s3/bucket-name/
```
