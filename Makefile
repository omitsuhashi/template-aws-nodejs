.PHONY: package deploy

# Find all TypeScript files in src/handler, excluding .d.ts files
TS_FILES := $(shell find src/handler -type f -name '*.ts' ! -name '*.d.ts')

# Convert the TypeScript file paths to their corresponding js file paths
JS_FILES := $(TS_FILES:src/handler/%/index.ts=dist/%/index.js)

PRISMA_SCHEMA_FILE := prisma/schema.prisma
PRISMA_GENERATE_FILE := node_modules/.prisma/client/index.js
PRISMA_LAYER_FILE := dist/layers/prisma/$(PRISMA_GENERATE_FILE)

$(PRISMA_GENERATE_FILE): $(PRISMA_SCHEMA_FILE)
	prisma generate

$(PRISMA_LAYER_FILE): $(PRISMA_GENERATE_FILE)
	mkdir -p dist/layers/prisma/node_modules/.prisma/client
	cp node_modules/.prisma/client/*.so.node dist/layers/prisma/node_modules/.prisma/client/
	cp node_modules/.prisma/client/*.prisma dist/layers/prisma/node_modules/.prisma/client/
	cp node_modules/.prisma/client/*.js dist/layers/prisma/node_modules/.prisma/client/
	cp -r node_modules/@prisma dist/layers/prisma/node_modules

# Rule for packaging and zipping TypeScript files
package: $(PRISMA_GENERATE_FILE) $(JS_FILES) $(PRISMA_LAYER_FILE)

# Rule for creating a zip file from a TypeScript file
dist/%/index.js: src/handler/%/index.ts
	mkdir -p $(dir $@)
	# Replace this with your actual TypeScript build command
	yarn webpack build ./$< --mode production --output-filename $(notdir $@) --output-path $(dir $@)

# Rule for deploying with Terraform
deploy: package $(PRISMA_LAYER_FILE)
	export WORKSPACE=$(NODE_ENV) && cd terraform && make workspace && make init && make apply
