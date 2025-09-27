karabiner:
	yq eval home-manager/dotfiles/karabiner/karabiner.yml -o=json > home-manager/dotfiles/karabiner/karabiner.json

.PHONY: karabiner