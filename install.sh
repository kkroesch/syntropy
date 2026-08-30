ln -s ${PWD}/syntropy/.zshrc ${HOME}
ln -s ${PWD}/syntropy/.zshenv ${HOME}
ln -s ${PWD}/syntropy/.alias ${HOME}
ln -s ${PWD}/syntropy/.config/git.plugin.zsh ${HOME}/.config/

eget direnv/direnv -to ${HOME}/.local/bin
eget direnv/direnv --to ${HOME}/.local/bin
eget junegunn/fzf --to ${HOME}/.local/bin
eget ajeetdsouza/zoxide --to ${HOME}/.local/bin
eget eza-community/eza --to ${HOME}/.local/bin

systemctl --user enable --now ssh-agent.service
