# Plugin input files
PLUGIN_FILES := plugin.yaml $(shell find contents -type f)

# Output location of the zipped plugin
LIBEXT_DIR := ~/rundeck/libext

# Local variables
PLUGIN_NAME := $(shell basename $$(pwd))
PLUGIN_ZIP := $(PLUGIN_NAME).zip
INSTALLED_PLUGIN_ZIP := $(LIBEXT_DIR)/$(PLUGIN_ZIP)

# Builds a zip of the plugin files
plugin: $(PLUGIN_ZIP)
$(PLUGIN_ZIP): $(PLUGIN_FILES)
	cd .. && zip $(PLUGIN_NAME)/$@ $$(for f in $(PLUGIN_FILES); do echo -n "$(PLUGIN_NAME)/$$f "; done)

# Installs the zipped plugin into the dir that rundeck looks for plugins
install: $(INSTALLED_PLUGIN_ZIP)
$(INSTALLED_PLUGIN_ZIP): $(PLUGIN_ZIP)
	cp $< $@

.PHONY: plugin install
