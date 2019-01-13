# NVIDIA GPUs on CoreOS Container Linux
Leveraging NVIDIA GPUs on Container Linux involves the following steps:
* compiling the NVIDIA kernel modules;
* loading the kernel modules on demand;
* creating NVIDIA device files; and
* loading NVIDIA libraries

Compounding this complexity further is the fact that these steps have to be executed whenever the Container Linux system updates since the modules may no longer be compatible with the new kernel.

Modulus takes care of automating all of these steps and ensures that kernel modules are up-to-date for the host's kernel.

## Installation for Kubernetes

### Requirements
You will need a running Kubernetes cluster and the `kubectl` command to deploy Modulus.

### Getting Started
Edit the provided Modulus DaemonSet to specify the version of NVIDIA you would like to compile, e.g. 390.48.
Then create the deployment:
```sh
kubectl apply -f daemonset.yaml
```

This DaemonSet will run on a Modulus pod on all the Kubernetes nodes.
You may choose to add a `nodeSelector` to schedule Modulus exclusively to nodes with GPUs.

## Installation for Systemd

### Requirements
First, make sure you have the [Modulus code available](https://github.com/squat/modulus#installation) on your Container Linux machine and that the `modulus` service is installed.

### Getting Started
Enable and start the `modulus` template unit file with the desired NVIDIA version, e.g. 390.48:
```sh
sudo systemctl enable modulus@nvidia-390.48
sudo systemctl start modulus@nvidia-390.48
```

This service takes care of automatically compiling, installing, backing up, and loading the NVIDIA kernel modules as well as creating the NVIDIA device files.

Compiling the NVIDIA kernel modules can take between 10-15 minutes depending on your Internet speed, CPU, and RAM. To check the progress of the compilation, run:
```sh
journalctl -fu modulus@nvidia-390.48
```

## Verify
Once Modulus has successfully run, the host should have NVIDIA device files and kernel modules loaded. To verify that the kernel modules were loaded, run:
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

Finally, try running the NVIDIA system monitoring interface (SMI) command, `nvidia-smi`, to check the status of the connected GPU:
```sh
/opt/drivers/nvidia/bin/nvidia-smi
```

If your GPU is connected, this command will return information about the model, temperature, memory usage, GPU utilization etc.

## Leveraging NVIDIA GPUs in Containers
Now that the kernel modules are loaded, devices are present, and libraries have been created, the connected GPU can be utilized in containerized applications.

In order to give the container access to the GPU, the device files must be explicitly loaded in the namespace, and the NVIDIA libraries and binaries must be mounted in the container. Consider the following command, which runs the `nvidia-smi` command inside of a Docker container:
```sh
docker run -it \
--device=/dev/nvidiactl \
--device=/dev/nvidia-uvm \
--device=/dev/nvidia0 \
--volume=/opt/nvidia:/usr/local/nvidia:ro \
--entrypoint=nvidia-smi \
nvidia/cuda:9.1-devel
```

There exist plugins that help with automating the loading of GPU devices in Docker containers; for more information, checkout the [NVIDIA-Docker](https://github.com/NVIDIA/nvidia-docker) repository.

## Leveraging NVIDIA GPUs in Kubernetes
In order to make use of the NVIDIA drivers and devices in your Kubernetes workloads, you will need to deploy a [Kubernetes device plugin](https://kubernetes.io/docs/concepts/cluster-administration/device-plugins/) for NVIDIA GPUs.
Drivers compiled with Modulus work seamlessly with the Kubernetes device plugin provided upstream in the [addons directory](https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/device-plugins/nvidia-gpu/daemonset.yaml) as well as the [official NVIDIA device plugin](https://github.com/NVIDIA/k8s-device-plugin).

Deploying the former requires no special NVIDIA container runtime and can be done with one command:
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/device-plugins/nvidia-gpu/daemonset.yaml
```

Once the device plugin is running, verify that the desired nodes have allocatable GPUs:
```sh
kubectl describe node <node-name>
```
