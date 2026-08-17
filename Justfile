VM_NAME := "desktop"

dotfiles:
	@tar czf dotfiles.tar.gz \
		.config \
		.gitconfig \
		.ssh \
		.zshenv \
		.zshrc

# ---------------------------------------- 
# Testing VM
# ---------------------------------------- 

vm:
	@virt-install \
  	--name fedora-test \
  	--memory 2048 \
  	--vcpus 2 \
  	--disk size=20,bus=virtio \
  	--location https://download.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/os/ \
  	--extra-args="console=ttyS0 inst.text" \
  	--extra-args="console=ttyS0 inst.text inst.ks=http://dein-webserver/kickstart.ks" \
  	--graphics none \
  	--network network=default,model=virtio \
  	--os-variant fedora-rawhide

snapshot:
	virsh snapshot-create-as desktop "clean-base" "Before Setup"

revert:
	virsh snapshot-revert desktop --snapshotname clean-base

shutdown:
	virsh shutdown desktop

clean:
	virsh destroy desktop
	virsh undefine --remove-all-storage desktop
