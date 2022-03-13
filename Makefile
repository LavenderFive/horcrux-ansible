# Functions
nam = $(firstword $(subst :, ,$1))
val = $(or $(word 2,$(subst ": ", , $1)),$(value 2))
hostarch:=linux_amd64
tmphorcruxVer := $(shell grep horcrux_version group_vars/all.yml)
tmphorcruxRepo := $(shell grep horcrux_repo group_vars/all.yml)
horcruxVer = $(subst $\',,$(call val,$(tmphorcruxVer)))
horcruxRepo =$(subst $\',,$(call val,$(tmphorcruxRepo)))
OUT_DIR:= hostbin
KEYS_DIR:= keys

HORCRUX_URL:= "${horcruxRepo}/releases/download/${horcruxVer}/horcrux_$(subst v,,${horcruxVer})_${hostarch}.tar.gz"
.DEFAULT_GOAL:= all
MKDIR_P = mkdir -p
HORCRUX_HOST:= ${OUT_DIR}/horcrux

.PHONY: directories 

${OUT_DIR}:
	${MKDIR_P} ${OUT_DIR}

${KEYS_DIR}:
	${MKDIR_P} ${KEYS_DIR}

directories: ${OUT_DIR} ${KEYS_DIR}

#
# Grab the latest horcrux binary defined by ansible's group_vars/all.yml
hostbinaries: directories
ifeq (,$(wildcard ${OUT_DIR}/horcrux))
	wget -O ${OUT_DIR}/horcrux.tgz ${HORCRUX_URL}
	tar -xf ${OUT_DIR}/horcrux.tgz -C ${OUT_DIR}
endif


#
# generate an empty config
#
emptyconfig: hostbinaries
ifeq (,$(wildcard ${KEYS_DIR}/config.yaml))
	touch ${KEYS_DIR}/config.yaml
endif

deps: hostbinaries
ifeq (,$(wildcard ${KEYS_DIR}/priv_validator_key.json))
	@echo "Missing priv_validator_key.json. Place it here: ${KEYS_DIR}/priv_validator_key.json"
	@false
else
	@echo "Priv validator key found ${KEYS_DIR}/priv_validator_key.json"
endif

#
# Generate keys from validator private key
#
genkeys: deps emptyconfig
	cd ${KEYS_DIR} && ../${HORCRUX_HOST} create-shares --home . priv_validator_key.json 2 3

test:
	@echo running ansible test..

usage:
	@echo Usage: make deps to check deps

clean:
	@rm -rf ${OUT_DIR}
	@echo ${OUT_DIR} is gone, but ${KEYS_DIR} is still there


all: genkeys
