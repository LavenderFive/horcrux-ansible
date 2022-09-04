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

## Vagrant (test environment)

It is recommended before you continue that you setup a local test enviroment with Vagrant. The example configuration above is already mapped out in the provided Vagrantfile.

Here's how to do get setup:
```
$sudo apt install virtualbox vagrant
$vagrant box add ubuntu/focal64
```
Install ansible version 2.12.1 (or greater)

Update virtualbox network config:
add the following line to /etc/vbox/networks.conf:
```
* 10.0.0.0/8
```
## Start your vms
```
$vagrant up
```
Make sure you can ssh into each vm without a password with the following: (NOTE: there is probably an easier way to do this step)
```
$ssh -i  ~/.vagrant.d/insecure_private_key vagrant@10.168.1.12
$ssh -i  ~/.vagrant.d/insecure_private_key vagrant@10.168.1.11
$ssh -i  ~/.vagrant.d/insecure_private_key vagrant@10.168.1.10
```

## Install 
Edit the makefile to make sure that `hostarch` is set properly for your ansible deploy enviroment. This is needed to download the correct LOCAL version of horcrux. Next you need a validator key. For this example you can grab any `priv_validator_key.json`.
```
$make deps
$cp priv_validator_key.json keys/
```

## Install horcrux
```
ansible-playbook -i inventory_vagrant.yml horcrux.yml  -e "target=horcrux_cluster"
```

## Configure horcrux state and start the cluster

Note it doesn't matter at this point what these values are. This is just for demonstration purposes.
The command below will update the following files in your horcrux cluster:
* `~/.horcrux/state/{chain-id}_priv_validator_state.json` 
* `~/.horcrux/state/{chain-id}_share_sign_state.json`

```
ansible-playbook -i inventory_vagrant.yml horcrux_state.yml  -e "target=horcrux_cluster block_height=361402 block_round=0 block_step=3 "
```


## Inspect your cluster
At this point your cluster should be running. Poke around at things and make sure things are working as intended. If there are any issues, now is the time to fix things.

Again go through the horcrux cluster. Ensure that the configuration files are correct and match up with the [horcrux](https://github.com/strangelove-ventures/horcrux/blob/main/docs/migrating.md) documentation.


# Server prep

Once you have things working in your local test environment, below are some guidelines on how to deploy to a live environment,

## prepare signer vms

Create 3 signer vms. Ensure that the `ansible_user` defined in inventory.yml is created and has sudo (no password) enabled. 

## update your inventory

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

### Install horcrux 

This step will create the horcrux user, install the latest version of horcrux, and setup an an initial config based on your inventory file.

```
ansible-playbook horcrux.yml  -e "target=horcrux_cluster"
```

If all goes well you should have your horcrux cluster all setup but not running yet. 

### Prep your full nodes

update `$NODE_HOME/config/config.toml` and ensure that the following line is present:

```
priv_validator_laddr = "tcp://0.0.0.0:1234"
```

Next ensure that ONLY your signer nodes have access to TCP port 1234. Strongly recommend that you use either a private network or at least a wireguard connection. Verify that the firewall rules are working now.


### Stop your validator

OK now comes the moment of truth. Stop your validator and examine `$NODE_HOME/data/priv_validator_state.json`. 
Take careful note of the following variables: `block_height`, `block_round` and `block_step`. Take note of them.

Next we will will update the following files on each signer node and restart the horcrux cluster:
* `~/.horcrux/state/{chain-id}_priv_validator_state.json` 
* `~/.horcrux/state/{chain-id}_share_sign_state.json`

Example run:
```
ansible-playbook horcrux_state.yml  -e "target=horcrux_cluster block_height=361402 block_round=0 block_step=3 "
```

### Restart your full nodes

Restart your full sentry nodes. If all goes well you should be up and running!

# Security considerations

Please read the horcrux [document](https://github.com/strangelove-ventures/horcrux/blob/main/docs/migrating.md) carefully and ensure that you understand all risks associated with key management.

## Cleanup

This ansible script creates a horcrux user (with limited capabilities).  It also requires `ansible_user` with full sudo access (no password). It is recommended that you completely remove this user after deploy, or at a minimum remove sudo access. Finally, the signer nodes should not expose ANY ports to the internet.

# Thanks!

If you would like content like, please consider supporting our [validator](https://www.mintscan.io/chihuahua/validators/chihuahuavaloper1y53zdszvt87fjg9hn50kg78850el26k0l9wxwl). You can stake with us at https://restake.app/chihuahua and https://restake.app/chihuahua.

