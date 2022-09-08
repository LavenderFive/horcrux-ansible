# Horcrux install from ansible


This ansible script will deploy a horcrux cluster, by first installing the latest version of horcrux. Next, it will initialize the configuration based on the cluster configuration described in `inventory.yml`. 

# Disclaimer

Security and management of any key material is challenging and is outside the scope of this software project.  It is recommended to test this out on a test network.

# No Liability
As far as the law allows, this software comes as is, without any warranty or condition, and no contributor will be liable to anyone for any damages related to this software or this license, under any kind of legal claim.

# Read up on the horcrux documentation
Read up on the horcrux documentation [ https://github.com/strangelove-ventures/horcrux/blob/main/docs/migrating.md ](Horcrux document). Make sure you read and understand the horcrux documentation (including the sample architecture). 

# Quickstart

Here is a sample configuration taken from the horcrux documentation:

```
# EXAMPLE configuration from horcrux documentation (Changed slightly to easily work with Vagrant)
sentry-1: 10.168.0.10
sentry-2: 10.168.0.11
sentry-3: 10.168.0.12

signer-1: 10.168.1.10
signer-2: 10.168.1.11
signer-3: 10.168.1.12
```
This example with 3 signer nodes and 3 sentry nodes is represented in `inventorysample.yml`. First make a copy of it to customize to your environment:

## Update your inventory

```
$ cp inventorysample.yml inventory.yml
```

Edit inventory.yml and update to mimic your environment. 

## Prepare network 

If on a bare metal environment, ensure that at a minimum you have wireguard access between each member of the horcrux cluster. Some hosting providers also provide a private network interface which is also an option.  Next, make sure that the signer cluster has private network access to each sentry.

## Prep local environment 

### Grab your `priv_validator_key.json` 

Place the priv_validator_key.json into the keys/ directory. 

```
$make deps
$cp priv_validator_key.json keys/
```

### Setup network configs

Under `group_vars` is an example.yml file you can use to base your network off of. 

### Install horcrux 

This step will create the horcrux user, install the latest version of horcrux, and setup an an initial config based on your inventory file.

```
ansible-playbook horcrux.yml  -e "target=akash"
```

If all goes well you should have your horcrux cluster all setup but not running yet. 

### Prep your full nodes

update `$NODE_HOME/config/config.toml` and ensure that the following line is present:

```
priv_validator_laddr = "tcp://0.0.0.0:1234"
```

Next ensure that ONLY your signer nodes have access to TCP port 1234. Strongly recommend that you use either a private network or at least a wireguard connection. Verify that the firewall rules are working now.

### Restart your full nodes

Restart your full sentry nodes. If all goes well you should be up and running!

# Security considerations

Please read the horcrux [document](https://github.com/strangelove-ventures/horcrux/blob/main/docs/migrating.md) carefully and ensure that you understand all risks associated with key management.

## Cleanup

This ansible script creates a horcrux user (with limited capabilities).  It also requires `ansible_user` with full sudo access (no password). It is recommended that you completely remove this user after deploy, or at a minimum remove sudo access. Finally, the signer nodes should not expose ANY ports to the internet.

