# Nvidia GPUs on CoreOS Container Linux
Leveraging nvidia GPUs on Container Linux involves the following steps:
* compiling the nvidia kernel modules;
* loading the kernel modules on demand;
* creating nvidia device files; and
* loading nvidia libraries

Compounding this complexity further is the fact that these steps have to be executed whenever the Container Linux system updates since the drivers may no longer be compatible with the new kernel.

Modulus takes care of automating all of these steps and ensures that the modules are up-to-date for the host's kernel.

## Requirements
First, make sure you have the [Modulus code available](https://github.com/squat/modulus#installation) on your Container Linux machine and that the `modulus` service is installed.

## Getting Started
Install and start the `create-devices` service with the instance name set to the version of nvidia you would like to compile, e.g. 381.22:
```sh
sudo cp /opt/modulus/nvidia/create-devices@.service /etc/systemd/system/create-devices@.service
sudo systemctl enable create-devices@381.22
sudo systemctl start create-devices@381.22
```

This service takes care of loading the nvidia kernel modules and creating the nvidia device files. It leverages the `modulus` service, which takes care of automatically compiling, installing, and backing up the kernel modules.

## Verify
Compiling the nvidia kernel modules can take between 10-15 minutes depending on your Internet speed, CPU, and RAM. To check the progress of the compilation, run:
```sh
journalctl -fu create-devices@381.22
```

Once the `create-devices` service successfully starts, the system should have nvidia device files and drivers loaded. To verify that the kernel modules were loaded, run:
```sh
lsmod | grep nvidia
```

This should return something like:
```sh
nvidia_uvm            626688  2
nvidia              12267520  35 nvidia_uvm
...
```

Verify that the devices were created with:
```sh
ls /dev/nvidia*
```

This should produce output like:
```sh
/dev/nvidia-uvm  /dev/nvidia0  /dev/nvidiactl
```

Finally, try running the nvidia system monitoring interface (SMI) command, `nvidia-smi`, to check the status of the connected GPU:
```sh
/opt/nvidia/381.22/bin/nvidia-smi
```

If your GPU is connected, this command will return information about the model, temperature, memory usage, GPU utilization etc.

## Leveraging Nvidia GPUs in Containers
Now that the kernel modules are loaded, devices are present, and libraries have been created, the connected GPU can be utilized in containerized applications.

In order to give the container access to the GPU, the device files must be explicitly loaded in the namespace, and the nvidia libraries and binaries must be mounted in the container. Consider the following command, which runs the `nvidia-smi` command inside of a Docker container:
```sh
docker run -it --device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia0 --volume=/opt/nvidia/381.22:/usr/local/nvidia:ro --entrypoint=nvidia-smi nvidia/cuda:8.0-cudnn5-devel
```

There exist plugins that help with automating the loading of GPU devices in Docker containers; for more information, checkout the [NVIDIA-Docker](https://github.com/NVIDIA/nvidia-docker) repository.
