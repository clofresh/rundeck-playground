SHELL := /bin/bash
PLUGIN_NAME := db-creds-plugin

# Make
RD_MAKE_STATE_DIR := .makestate

# Docker
CONTAINER_PREFIX := $(shell basename $$(pwd))_
NETWORK_NAME := $(CONTAINER_PREFIX)default
NUM_WEB := 2

# Command to call the Rundeck client from outside of the container
RD := docker run --network $(NETWORK_NAME) --mount type=bind,source="$$(pwd)",target=/root playground-rundeck-cli

# Plugin
PLUGIN_SRC_DIR := $(PLUGIN_NAME)
PLUGIN_FILES := $(PLUGIN_SRC_DIR)/plugin.yaml $(shell find $(PLUGIN_SRC_DIR)/contents -type f)
INSTALLED_PLUGIN_ZIP := rundeck/$(PLUGIN_NAME).zip
RD_PLUGIN_STATE := $(RD_MAKE_STATE_DIR)/$(PLUGIN_NAME)
RUNDECK_CONTAINER := $(CONTAINER_PREFIX)rundeck_1
RUNDECK_CONTAINER_LIBEXT := /home/rundeck/libext

# Runs docker-compose to spin up the full environment
compose: $(INSTALLED_PLUGIN_ZIP)
	docker-compose up --build

# Builds a zip of the plugin files
$(INSTALLED_PLUGIN_ZIP): $(PLUGIN_FILES)
	zip $@ $(PLUGIN_FILES)

# Installs the plugin into the Rundeck container's plugin directory
plugin: $(RD_PLUGIN_STATE)
$(RD_PLUGIN_STATE): $(INSTALLED_PLUGIN_ZIP)
	docker cp $< $(RUNDECK_CONTAINER):/tmp/
	docker exec $(RUNDECK_CONTAINER) \
		/bin/bash -c 'chown rundeck:rundeck /tmp/*-plugin.zip \
			&& mv /tmp/*-plugin.zip $(RUNDECK_CONTAINER_LIBEXT)/'
	touch $@

# Creates the Rundeck project and sets its config properties
RD_PROJECT := hello-project
RD_PROJECT_CONFIG_DIR := rundeck-project
RD_PROJECT_STATE := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)
$(RD_PROJECT_STATE): $(RD_PROJECT_CONFIG_DIR)/project.properties
	$(RD) projects create -p $(RD_PROJECT) || true
	$(RD) projects configure update  -p $(RD_PROJECT) --file $<
	touch $@

# Installs the Rundeck job configuration
RD_JOBS_ALL := $(RD_MAKE_STATE_DIR)/all.yaml
RD_JOB_FILES = $(shell find rundeck-project -name '*.yaml')

$(RD_JOBS_ALL): $(RD_JOB_FILES) $(RD_PROJECT_STATE)
	cat $^ > $@
	$(RD) jobs load -f $@ --format yaml -p $(RD_PROJECT)

# Installs the ssh password into the Rundeck Key Storage
RD_KEYS_SSH := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)-ssh-passwords
$(RD_KEYS_SSH): ssh/ssh.password
	for i in $$(seq 1 $(NUM_WEB)); do \
		$(RD) keys create \
			-f $< \
			--path keys/projects/$(RD_PROJECT)/nodes/web_$${i}/ssh.password \
			-t password; \
	done
	touch $@

# Installs the db user passwords into the Rundeck Key Storage
RD_KEYS_DB_PREFIX := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)-db-login
RD_KEYS_DB := $(RD_KEYS_DB_PREFIX)-master1 $(RD_KEYS_DB_PREFIX)-web1 $(RD_KEYS_DB_PREFIX)-web2
$(RD_KEYS_DB_PREFIX)-%: database/users/%
	$(RD) keys create -t password -f $< \
		--path keys/projects/$(RD_PROJECT)/db/$$(basename $<)
	touch $@

# Installs the secrets into the Rundeck Key Storage
RD_KEYS_STATES := $(RD_KEYS_SSH) $(RD_KEYS_DB)
keys: $(RD_KEYS_STATES)

# Installs all the Rundeck config, keys and plugin
rd-config: $(RD_PLUGIN_STATE) $(RD_JOBS_ALL) $(RD_KEYS_STATES) $(RD_KEYS_DB)

# Triggers a Rundeck job
JOB ?= Hello Test Job
rd-run-job: rd-config
	$(RD) run -p $(RD_PROJECT) -f --job '$(JOB)'

# Updates the web.py file in the running containers to simulate a deployment
update-web:
	for i in $(shell seq 1 $(NUM_WEB)); do \
		container=$(CONTAINER_PREFIX)web_$${i}_1; \
		docker cp web/web.py $${container}:/usr/share/web.py; \
	done

# Clears all file and docker state created by this project
clean: clean-makestate clean-docker

# Clears the make state files
clean-makestate:
	rm -f $(RD_MAKE_STATE_DIR)/* $(INSTALLED_PLUGIN_ZIP)

# Clears all the docker images, containers, network and volumes
clean-docker:
	docker-compose down --rmi all -v

# Don't confuse these recipes with files
.PHONY: compose plugin rd-config rd-run-job update-web keys clean clean-makestate
