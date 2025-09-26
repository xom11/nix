compile:
	yq eval karabiner.yml -o=json > karabiner.json

install: compile
	mkdir -p $$HOME/.config/karabiner/assets/complex_modifications/
	cp karabiner.json $$HOME/.config/karabiner/assets/complex_modifications/

all:
	mkdir -p $$HOME/.config/karabiner/
	cp karabiner.json $$HOME/.config/karabiner/

.PHONY: compile,install,all