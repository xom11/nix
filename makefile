karabiner:
	yq eval home-manager/dotfiles/karabiner/karabiner.yml -o=json > home-manager/dotfiles/karabiner/karabiner.json
	cp home-manager/dotfiles/karabiner/karabiner.json $$HOME/.config/karabiner/karabiner.json
	karabiner_cli --select-profile "Default profile"

.PHONY: karabiner