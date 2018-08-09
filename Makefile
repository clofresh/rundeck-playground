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
NUM_WEB := 2

compose: $(INSTALLED_PLUGIN_ZIP)
	docker-compose up --build --scale web=$(NUM_WEB)

# Builds a zip of the plugin files
RD := docker run --network rundeck-custom-plugin-example_default --mount type=bind,source="$$(pwd)",target=/root rd-example-rundeck-cli
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
				 $(RD_MAKE_STATE_DIR)/create_db_user.job

$(RD_MAKE_STATE_DIR)/%.job: $(RD_PROJECT_CONFIG_DIR)/%.yaml $(RD_PROJECT_STATE)
	$(RD) jobs load -f $<  --format yaml -p $(RD_PROJECT) && touch $@

SSH_PASSWORD_FILE := ssh/ssh.password
RD_KEYS_SSH := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)-ssh-passwords
RD_KEYS_DB := $(RD_MAKE_STATE_DIR)/$(RD_PROJECT)-db-login
RD_KEYS_STATES := $(RD_KEYS_SSH) $(RD_KEYS_DB)

$(RD_KEYS_SSH): $(SSH_PASSWORD_FILE)
	for i in $$(seq 1 $(NUM_WEB)); do \
		$(RD) keys create \
			-f $< \
			--path keys/projects/$(RD_PROJECT)/nodes/web_$${i}/ssh.password \
			-t password; \
	done
	touch $@

$(RD_KEYS_DB): database/master_db_user.txt database/master_db_password.txt database/db_user.txt database/db_password.txt
	$(RD) keys delete -p keys/projects/$(RD_PROJECT)/db/master-user || true
	$(RD) keys create -t password -f database/master_db_user.txt \
		--path keys/projects/$(RD_PROJECT)/db/master-user

	$(RD) keys delete -p keys/projects/$(RD_PROJECT)/db/master-password || true
	$(RD) keys create -t password -f database/master_db_password.txt \
		--path keys/projects/$(RD_PROJECT)/db/master-password

	$(RD) keys delete -p keys/projects/$(RD_PROJECT)/db/user || true
	$(RD) keys create -t password -f database/db_user.txt \
		--path keys/projects/$(RD_PROJECT)/db/user

	$(RD) keys delete -p keys/projects/$(RD_PROJECT)/db/password || true
	$(RD) keys create -t password -f database/db_password.txt \
		--path keys/projects/$(RD_PROJECT)/db/password
	touch $@

rd-config: $(RD_PLUGIN_STATE) $(RD_JOB_STATES) $(RD_KEYS_STATES)

JOB ?= Hello Test Job
rd-run-job: rd-config
	$(RD) run -p $(RD_PROJECT) -f --job '$(JOB)'

update-web:
	for i in $(shell seq 1 $(NUM_WEB)); do \
		container=rundeck-custom-plugin-example_web_$${i}; \
		docker cp web/web.py $${container}:/usr/share/web.py; \
	done

.PHONY: compose plugin rd-config rd-run-job update-web
