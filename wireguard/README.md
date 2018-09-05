# WireGuard on CoreOS Container Linux
Leveraging WireGuard on Container Linux involves the following steps:
* compiling the WireGuard kernel module; and
* loading the kernel module on demand

These steps have to be executed whenever the Container Linux system updates since the modules may no longer be compatible with the new kernel.

Modulus takes care of automating all of these steps and ensures that kernel modules are up-to-date for the host's kernel.

## Installation for Kubernetes

### Requirements
You will need a running Kubernetes cluster and the `kubectl` command to deploy Modulus.

### Getting Started
Edit the provided Modulus daemonset to specify the version of WireGuard you would like to compile, e.g. 0.0.20180904.
Then create the deployment:
```sh
kubectl apply -f daemonset.yaml
```

This daemonset will run on a Modulus pod on all the Kubernetes nodes.

## Verify
Once Modulus has successfully run, the host should have the WireGuard kernel module loaded. To verify that the kernel module was loaded, run:
```sh
lsmod | grep wireguard
```

This should return something like:
```sh
wireguard             233472  0
ip6_udp_tunnel         16384  1 wireguard
udp_tunnel             16384  1 wireguard
```

Finally, try creating a WireGuard interface and using the WireGuard binary, `wg`, to inspect it:
```sh
sudo ip link add dev wg0 type wireguard && sudo /opt/drivers/wireguard/bin/wg show all && sudo ip link del wg0
```

This should produce some output like:
```
interface: wg0
  listening port: 43217
```
