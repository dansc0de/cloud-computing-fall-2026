# Week 02 - Virtualization & Multipass

## Topics

- **Block A:** Hypervisors, VM anatomy, hardware virtualization (VT-x / AMD-V)
- **Block B:** Multipass lab — launch, cloud-init, exec

## Lab: Multipass + cloud-init

### Launch a VM with cloud-init

```bash
multipass launch --name my-vm --cloud-init init-mp.yaml
```

This uses `init-mp.yaml` to automatically:
- Install `apache2` and `git`
- Enable and start the Apache web server
- Write `H2P` to the default web page

### Verify the web server

```bash
# Get the VM's IP address
multipass info my-vm

# Test the web server
curl http://<vm-ip>
```

### Useful Multipass commands

```bash
multipass shell my-vm       # open a shell inside the VM
multipass exec my-vm -- <cmd>  # run a command inside the VM
multipass list              # list all instances
multipass stop my-vm        # stop the VM
multipass delete my-vm      # mark for deletion
multipass purge             # permanently remove deleted VMs
```

## Files

| File | Description |
|------|-------------|
| `init-mp.yaml` | cloud-init config that provisions an Ubuntu VM with Apache |
