karabiner:
	yq eval home-manager/dotfiles/karabiner/karabiner.yml -o=json > home-manager/dotfiles/karabiner/karabiner.json
	rm -f $$HOME/.config/karabiner/karabiner.json
	mv home-manager/dotfiles/karabiner/karabiner.json $$HOME/.config/karabiner
	karabiner_cli --select-profile "Default profile"

.PHONY: karabiner