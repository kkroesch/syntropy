VM_NAME := "debian-desktop"

vm:
	virt-install \
		--name debian-desktop \
		--memory 2048 \
		--vcpus 2 \
		--disk size=20,bus=virtio \
		--location https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/ \
		--extra-args="console=ttyS0" \
		--graphics none \
		--network network=default,model=virtio \
		--os-variant debian13 

snapshot:
	virsh snapshot-create-as debian-desktop "clean-base" "Before Setup"

revert:
	virsh snapshot-revert debian-desktop --snapshotname clean-base

shutdown:
	virsh shutdown debian-desktop

clean:
	virsh destroy debian-desktop
	virsh undefine --remove-all-storage debian-desktop
