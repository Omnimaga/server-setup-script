#!/bin/bash
# Functions for logging
section(){
	echo "=> Starting Section \"$@\"";
}
log(){
	echo "|-> $@";
}
sublog(){
	echo "|--> $@";
}
info(){
	echo "|-> INFO: $@";
}
subinfo(){
	echo "|--> INFO $@";
}
install(){
	apt-get -qq install $@;
}
updatesudo(){
	if visudo -q -c -fdata/etc/$@;then
		cp data/etc/$@ /etc/$@;
	fi;
}
# Make sure the script is running as root
if [ "$(id -u)" != "0" ]; then
	sudo $0;
	exit;
fi;
# Actually run the install
section "Package Installation";
log "LAMP Stack";
install lamp-server^;
log "Node.js"
install nodejs;
log "SSH Server";
install ssh;
log "Git";
install git;
log "htop";
install htop;

section "Custom Packages";
log "Omnimaga-Server-Utils";
sublog "Creating directories";
mkdir /opt/omnimaga/bin -p;
chown root:users /opt/omnimaga/bin;
sublog "Adding to path";
echo "export PATH=$PATH:/opt/omnimaga/bin;" > /etc/profile.d/omnimaga-server-utils.sh;
. /etc/profile.d/omnimaga-server-utils.sh;
sublog "getting files";
rm -rf /opt/omnimaga/bin;
git clone https://github.com/Omnimaga/server-utils.git /opt/omnimaga/bin/;
chmod a+x /opt/omnimaga/bin/*;
subinfo "Add users to the group omnimaga-utils to allow access";


section "Config";
log "Setting up sudoers";
updatesudo sudoers;
log "Setting up groups";
sublog "web";
groupadd -f web;
updatesudo sudoers.d/web;
sublog "ircd";
groupadd -f ircd;
updatesudo sudoers.d/ircd;