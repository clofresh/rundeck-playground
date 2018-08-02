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
RUNDECK_CONTAINER := rundeck-custom-plugin-example_rundeck_1
RUNDECK_CONTAINER_LIBEXT := /home/rundeck/libext

compose: $(INSTALLED_PLUGIN_ZIP)
	docker-compose up --build

# Builds a zip of the plugin files
RD := docker run --network rundeck-custom-plugin-example_default --mount type=bind,source="$$(pwd)",target=/root rd-example-rundeck-cli
RD_PROJECT_CONFIG_DIR := rundeck-project
RD_MAKE_STATE_DIR := $(RD_PROJECT_CONFIG_DIR)/state
RD_PROJECT := hello-project
RD_JOB := hello_test_job
RD_PROJECT_PROPERTIES := $(RD_PROJECT_CONFIG_DIR)/project.properties
SSH_PASSWORD_FILE := ssh/ssh.password

RD_PROJECT_STATE := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)
RD_JOB_STATE := $(RD_MAKE_STATE_DIR)/$(RD_JOB)
RD_KEYS_STATE := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)-ssh-passwords

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

$(RD_JOB_STATE): $(RD_PROJECT_CONFIG_DIR)/$(RD_JOB).yaml $(RD_PROJECT_STATE) $(RD_PLUGIN_STATE)
	echo $?
	$(RD) jobs load -f $<  --format yaml -p $(RD_PROJECT) && touch $@

$(RD_KEYS_STATE): $(SSH_PASSWORD_FILE)
	for node in $$(docker-compose config --services | grep web); do \
		$(RD) keys create \
			-f $< \
			--path keys/projects/$(RD_PROJECT)/nodes/$$node/ssh.password \
			-t password; \
	done
	touch $@

rd-config: $(RD_JOB_STATE) $(RD_KEYS_STATE)

rd-run-job: rd-config
	$(RD) run -p $(RD_PROJECT) -f --job 'Hello Test Job'

.PHONY: compose plugin rd-config rd-run-job
