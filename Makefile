ELM_FLAGS = --optimize
#ELM_FLAGS =
CONTRIB_DIR = ./src/contrib
SRC_DIR = ./src
JS_DIR =  ./js
CONTENTS_DIR = ./contents
JS_CONTRIB_DIR =  $(JS_DIR)/contrib
LS_CONTRIB_SRC = $(wildcard $(CONTRIB_DIR)/*.ls)
LS_CONTRIB_OUT = $(addsuffix .js, $(addprefix $(JS_CONTRIB_DIR)/, $(notdir $(basename $(LS_CONTRIB_SRC)))))
LS_SRC = $(wildcard $(SRC_DIR)/*.ls)
LS_OUT = $(addsuffix .js, $(addprefix $(JS_DIR)/, $(notdir $(basename $(LS_SRC)))))
ELM_SRC = $(SRC_DIR)/Main.elm
ELM_OUT = $(JS_DIR)/elm.js

target: app.zip

init:
	npm install

run: bundle.js
	@cd $(CONTENTS_DIR); npx serve -s

app.zip: bundle.js
	zip -r app.zip version.txt setting.txt contents/*

elm.js: $(ELM_SRC)
	@if [ ! -d $(JS_DIR) ]; then mkdir -p $(JS_DIR); fi
	npm run-script build:dev

$(JS_DIR)/%.js: $(SRC_DIR)/%.ls
	@if [ ! -d $(JS_DIR) ]; then mkdir -p $(JS_DIR); fi
	npm run-script lsc -- -o $(JS_DIR) $<

$(JS_CONTRIB_DIR)/%.js: $(CONTRIB_DIR)/%.ls
	@if [ ! -d $(JS_CONTRIB_DIR) ]; then mkdir -p $(JS_CONTRIB_DIR); fi
	npm run-script lsc -- -o $(JS_CONTRIB_DIR) $<

bundle.js: elm.js $(LS_OUT)
	npm run-script browserify -- $(JS_DIR)/app.js --outfile contents/bundle.js

clean:
	@rm -rf js
	@rm -f app.zip
	@rm -f package-lock.json

reset:
	@rm -r node_modules
	@rm -r elm-stuff
	@rm -rf js
	@rm -f app.zip
	@rm -f package-lock.json

