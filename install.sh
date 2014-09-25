#!/bin/bash
# Config
ENVIROMENT="prod";
TMP="/tmp/omni-setup";
if [[ "$1" != "" ]];then
	ENVIROMENT="$1";
fi;
REGISTER_URL="http://api.omnimaga.org/register/$ENVIROMENT";
PHPMYADMIN_URL="http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.2.9/phpMyAdmin-4.2.9-english.tar.xz";
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

section "Registering";
log "Getting IDs";
mkdir -p /tmp/omni-setup;
sublog "Hostname";
wget -q "$REGISTER_URL/hostname" -O $TMP/hostname;
if [[ "$(cat $TMP/hostname)" == "" ]];then
	hostname > $TMP/hostname;
fi;
hostname $(cat $TMP/hostname);
cp $TMP/hostname /etc/hostname;
sublog "MySQL ID";
wget -q "$REGISTER_URL/mysql-id" -O $TMP/mysql-id;

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
git clone -q https://github.com/Omnimaga/server-utils.git /opt/omnimaga/bin/;
chmod a+x /opt/omnimaga/bin/*;
subinfo "Add users to the group omnimaga-utils to allow access";
log "phpmyadmin";
sublog "Downloading";
wget -q $PHPMYADMIN_URL -O $TMP/pma.tar.xz;
sublog "Extracting";
tar -C $TMP/ -xf $TMP/pma.tar.xz;
sublog "Copying";
mkdir -p /var/www/phpmyadmin/;
cp -R $TMP/phpMyAdmin-*/{*,.[a-zA-Z0-9]*} /var/www/phpmyadmin/;
cp data/var/www/phpmyadmin/config.inc.php /var/www/phpmyadmin/;

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
sublog "mysqld";
cp data/etc/mysql/conf.d/replication.cnf /etc/mysql/conf.d/replication.cnf;
