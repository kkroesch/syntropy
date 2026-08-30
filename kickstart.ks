# Installation im Textmodus
text
# Sprach- und Tastatureinstellungen
lang en_US.UTF-8
keyboard ch
# Minimal-Installation ohne GUI
minimal
# Netzwerk-Config
network --bootproto=dhcp --device=link --activate
# Root-Passwort setzen (oder user erstellen)
rootpw --plaintext ChangeMe!
# Partitionierung automatisch (auf der ersten Disk)
clearpart --all --initlabel
autopart
# Reboot nach Installation
reboot

%packages
@core
# Füge hier deine Lieblings-Tools hinzu, z.B. podman, vim, git
podman
vim
git
%end
