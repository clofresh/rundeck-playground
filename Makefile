SHELL := /bin/bash
PLUGIN_SRC_DIR := helloworld-plugin

# Plugin input files
PLUGIN_FILES := $(PLUGIN_SRC_DIR)/plugin.yaml $(shell find $(PLUGIN_SRC_DIR)/contents -type f)

# Output location of the zipped plugin
OUTPUT_DIR := rundeck

# Local variables
PLUGIN_NAME := $(PLUGIN_SRC_DIR)
PLUGIN_ZIP := $(PLUGIN_NAME).zip
INSTALLED_PLUGIN_ZIP := $(OUTPUT_DIR)/$(PLUGIN_ZIP)

# Docker variables
CONTAINER_PREFIX := $(shell basename $$(pwd))_
NETWORK_NAME := $(CONTAINER_PREFIX)default
RUNDECK_CONTAINER := $(CONTAINER_PREFIX)rundeck_1
RUNDECK_CONTAINER_LIBEXT := /home/rundeck/libext
NUM_WEB := 2

compose: $(INSTALLED_PLUGIN_ZIP)
	docker-compose up --build

# Builds a zip of the plugin files
RD := docker run --network $(NETWORK_NAME) --mount type=bind,source="$$(pwd)",target=/root playground-rundeck-cli
RD_PROJECT_CONFIG_DIR := rundeck-project
RD_MAKE_STATE_DIR := $(RD_PROJECT_CONFIG_DIR)/state
RD_PROJECT := hello-project
RD_JOB := hello_test_job
RD_PROJECT_PROPERTIES := $(RD_PROJECT_CONFIG_DIR)/project.properties

RD_PROJECT_STATE := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)
RD_PLUGIN_STATE := $(RD_MAKE_STATE_DIR)/$(PLUGIN_NAME)

plugin: $(RD_PLUGIN_STATE)
$(RD_PLUGIN_STATE): $(INSTALLED_PLUGIN_ZIP)
	docker cp $< $(RUNDECK_CONTAINER):$(RUNDECK_CONTAINER_LIBEXT)/
	touch $@

$(INSTALLED_PLUGIN_ZIP): $(PLUGIN_FILES)
	mkdir -p $$(dirname $(INSTALLED_PLUGIN_ZIP))
	zip $@ $(PLUGIN_FILES)

$(RD_PROJECT_STATE): $(RD_PROJECT_PROPERTIES)
	mkdir -p $$(dirname $(RD_PROJECT_STATE))
	$(RD) projects create -p $(RD_PROJECT) || true
	$(RD) projects configure update  -p $(RD_PROJECT) --file $(RD_PROJECT_PROPERTIES)
	touch $@

RD_JOB_STATES := $(RD_MAKE_STATE_DIR)/hello_test_job.job \
				 $(RD_MAKE_STATE_DIR)/restart.job \
				 $(RD_MAKE_STATE_DIR)/change_password.job \
				 $(RD_MAKE_STATE_DIR)/create_db_user.job \
				 $(RD_MAKE_STATE_DIR)/rotate_db_password.job

$(RD_MAKE_STATE_DIR)/%.job: $(RD_PROJECT_CONFIG_DIR)/%.yaml $(RD_PROJECT_STATE)
	$(RD) jobs load -f $<  --format yaml -p $(RD_PROJECT) && touch $@

SSH_PASSWORD_FILE := ssh/ssh.password
RD_KEYS_SSH := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)-ssh-passwords
RD_KEYS_DB_PREFIX := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)-db-login
RD_KEYS_DB := $(RD_KEYS_DB_PREFIX)-master1 $(RD_KEYS_DB_PREFIX)-web1 $(RD_KEYS_DB_PREFIX)-web2
RD_KEYS_STATES := $(RD_KEYS_SSH) $(RD_KEYS_DB)

$(RD_KEYS_SSH): $(SSH_PASSWORD_FILE)
	for i in $$(seq 1 $(NUM_WEB)); do \
		$(RD) keys create \
			-f $< \
			--path keys/projects/$(RD_PROJECT)/nodes/web_$${i}/ssh.password \
			-t password; \
	done
	touch $@

keys: $(RD_KEYS_DB)
$(RD_KEYS_DB_PREFIX)-%: database/users/%
	$(RD) keys create -t password -f $< \
		--path keys/projects/$(RD_PROJECT)/db/$$(basename $<)
	touch $@

rd-config: $(RD_PLUGIN_STATE) $(RD_JOB_STATES) $(RD_KEYS_STATES) $(RD_KEYS_DB)

JOB ?= Hello Test Job
rd-run-job: rd-config
	$(RD) run -p $(RD_PROJECT) -f --job '$(JOB)'

update-web:
	for i in $(shell seq 1 $(NUM_WEB)); do \
		container=$(CONTAINER_PREFIX)web_$${i}_1; \
		docker cp web/web.py $${container}:/usr/share/web.py; \
	done

clean: clean-make-state clean-docker

clean-make-state:
	rm $(RD_MAKE_STATE_DIR)/*

clean-docker:
	docker-compose down --rmi all -v

.PHONY: compose plugin rd-config rd-run-job update-web keys clean clean-make-state
