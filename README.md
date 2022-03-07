# Horcrux install from ansible

This ansible script will deploy a horcrux cluster, by first installing the latest version of horcrux. Next, it will initialize the configuration based on the cluster configuration described in `inventory.yml`. 

# Disclaimer

Security and management of any key material is challenging and is outside the scope of this software project.  It is recommended to test this out on a test network.

# No Liability
As far as the law allows, this software comes as is, without any warranty or condition, and no contributor will be liable to anyone for any damages related to this software or this license, under any kind of legal claim.

# Read up on the horcrux documentation

Read up on the horcrux documentation [ https://github.com/strangelove-ventures/horcrux/blob/main/docs/migrating.md ](Horcrux document). Make sure you understand the sample architecture. 

## quickstart

Here is a sample configuration taken from the horcrux documentation:

```
# EXAMPLE configuration from horcrux documentation
sentry-1: 10.168.0.1
sentry-2: 10.168.0.2
sentry-3: 10.168.0.3

signer-1: 10.168.1.1
signer-2: 10.168.1.2
signer-3: 10.168.1.3
```
This example with 3 signer nodes and 3 sentry nodes is represented in `inventory_sample.yml`. First make a copy of it to customize to your environment:

```
$ cp inventorysample.yml inventory.yml
```
# Server prep

You will need to run this ansible script somewhere that has ssh access (with sudo) for the signer VM's. As a side note, once this is deployed, you will need to do a post deply security cleanup. Such as removing sudo access from the `ansible_user` user set in inventory.yml. You will need to create this user on all signer boxes and ensure the user has sudo (no password) enabled.

## Run the playbook

```
ansible-playbook -i inventorysample.yml horcrux.yml  -e "target=horcrux_cluster"
```

# Security considerations

Please read the horcrux [ https://github.com/strangelove-ventures/horcrux/blob/main/docs/migrating.md ](document) carefully and ensure that you understand all risks associated with key management.

## Cleanup

This ansible script creates a horcrux user (with limited capabilities).  It also requires `ansible_user` with full sudo access (no password). It is recommended that you completely remove this user after deploy, or at a minimum remove sudo access.
