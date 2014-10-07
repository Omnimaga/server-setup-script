#!/bin/bash
# Config
ENVIROMENT="prod";
TMP="/tmp/omni-setup";
if [[ "$1" != "" ]];then
	ENVIROMENT="$1";
fi;
REGISTER_URL="http://api.omnimaga.org/register/$ENVIROMENT";
PHPMYADMIN_URL="http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.2.9/phpMyAdmin-4.2.9.1-english.tar.xz";
UNREALIRCD_URL="https://www.unrealircd.org/downloads/Unreal3.2.10.4.tar.gz";
# Functions for logging
section(){
# section <message>
	echo "=> Starting Section \"$@\"";
}
log(){
# log <message>
	echo "|-> $@";
}
sublog(){
# sublog <message>
	echo "|--> $@";
}
info(){
# info <message>
	echo "|-> INFO: $@";
}
subinfo(){
# subinfo <message>
	echo "|--> INFO $@";
}
install(){
# install <packages>
	apt-get -qq install $@;
}
updatesudo(){
# updatesudo <path>
	if visudo -q -c -fdata/etc/$1;then
		cp data/etc/$1 /etc/$1;
	fi;
}
site(){
# site <site>
	cp data/etc/apache2/sites-available/$1.conf /etc/apache2/sites-available/$1.conf;
	a2ensite $1;
}
host(){
# host <host> [<ip>]
	local ip=$2;
	if [[ "$ip" == "" ]];then
		ip="127.0.0.1";
	fi;
	HOSTS=$HOSTS"$ip\t$1\n";
}
download(){
	local url=$1;
	local path=$2;
	echo -n "    ";
	wget --progress=dot $url -O $path 2>&1 | grep --line-buffered "%" | sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}';
	echo -ne "\b\b\b\b";
}
clone(){
	git clone -q $1 $2;
}
# Make sure the script is running as root
if [ "$(id -u)" != "0" ];then
	echo "Running with sudo";
	sudo $0;
	exit;
fi;
# Actually run the install

section "Registering";
log "Getting IDs";
mkdir -p /tmp/omni-setup;
sublog "Hostname";
download "$REGISTER_URL/hostname" $TMP/hostname;
if [[ "$(cat $TMP/hostname)" == "" ]];then
	hostname > $TMP/hostname;
fi;
download "$REGISTER_URL/replication_id" $TMP/replication_id;
if [[ "$(cat $TMP/replication_id)" == "" ]];then
	echo 1 > $TMP/replication_id;
fi;
hostname $(cat $TMP/hostname);
HOSTS="127.0.0.1\tlocalhost\n127.0.0.1\t$(hostname)\n::1\t\tlocalhost ip6-localhost ip6-loopback\nff02::1\t\tip6-allnodes\nff02::2\t\tip6-allrouters\n";
cp $TMP/hostname /etc/hostname;
sublog "MySQL ID";
download "$REGISTER_URL/mysql-id" $TMP/mysql-id;

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
log "zsh";
install zsh;
log "openssl";
install openssl;
log "build tools";
install build-essential;
install libcurl4-openssl-dev

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
clone https://github.com/Omnimaga/server-utils.git /opt/omnimaga/bin/;
chmod a+x /opt/omnimaga/bin/*;
subinfo "Add users to the group omnimaga-utils to allow access";
log "phpmyadmin";
sublog "Downloading";
download $PHPMYADMIN_URL $TMP/pma.tar.xz;
sublog "Extracting";
tar -C $TMP/ -xf $TMP/pma.tar.xz;
sublog "Copying";
mkdir -p /var/www/phpmyadmin/;
cp -R $TMP/phpMyAdmin-*/{*,.[a-zA-Z0-9]*} /var/www/phpmyadmin/;
cp data/var/www/phpmyadmin/config.inc.php /var/www/phpmyadmin/;
chown www-data:www-data /var/www/phpmyadmin -R;
log "unrealircd";
download $UNREALIRCD_URL $TMP/unreal.tar.gz;
adduser --system --no-create-home ircd;
mkdir -p /opt/unrealircd;
tar -C $TMP/ -xf $TMP/unreal.tar.gz
cp -R $TMP/Unreal*/{*,.[a-zA-Z0-9]*} /opt/unrealircd;
cp data/opt/unrealircd/config.settings /opt/unrealircd;
pushd;
cd /opt/unrealircd;
./Config -quick -nointro;
make;
popd;

section "Config";
log "Sudoers";
updatesudo sudoers;
log "Groups";
sublog "web";
groupadd -f web;
updatesudo sudoers.d/web;
sublog "ircd";
groupadd -f ircd;
updatesudo sudoers.d/ircd;
log "Services";
sublog "mysqld";
cp data/etc/mysql/conf.d/replication.cnf /etc/mysql/conf.d/replication.cnf;
service mysql reload;
sublog "apache2";
a2enmod -q vhost_alias;
a2enmod -q rewrite;
site omnimaga;
site pma;
sed -i "s/__SERVER_HOSTNAME__/$(cat $TMP/hostname)/" /etc/apache2/sites-available/pma.conf;
service apache2 reload;
log "Core";
sublog "shell";
cp data/etc/adduser.conf /etc/adduser.conf;
cp data/etc/default/useradd /etc/default/useradd;
grep -v nologin /etc/passwd | grep -v /bin/false | grep -v /bin/sync | grep -v /var/lib/libuuid | cut -d : -f 1 | while read user;do
	chsh -s /bin/zsh $user;
	info "Changed shell for $user";
done;
sublog "hosts";
host omnimaga.org;
host www.omnimaga.org;
host $(hostname).omnimaga.org;
host pma.$(hostname).omnimaga.org;
echo -e $HOSTS > /etc/hosts;
sublog "phpmyadmin";
echo -n "root@localhost mysql pass:";
read -s pass;
cat /var/www/phpmyadmin/examples/create_tables.sql | mysql -u root -p"$pass";