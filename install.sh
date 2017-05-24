#!/bin/bash
#------------------------------------------------------------------------------------------------------------
USERNAME="mailru"
SCRIPTS_DIR="/home/${USERNAME}/scripts"
INI_CONFIG="${SCRIPTS_DIR}/scripts.ini"
UPD_TIME=30
#------------------------------------------------------------------------------------------------------------
RED='\033[0;31m'
BLU='\033[0;34m'
NCC='\033[0m'
#------------------------------------------------------------------------------------------------------------
# Find location of scrit
BASEDIR=`dirname $0`
PROJECT_PATH=`cd $BASEDIR; pwd`
#------------------------------------------------------------------------------------------------------------
# Check the script is being run by root
if [ "$(id -u)" != "0" ]; then
	echo -e "${RED}This script must be run as root!${NCC}"
	sudo $PROJECT_PATH/install.sh; exit 0;
fi
#------------------------------------------------------------------------------------------------------------
# Add newuser for syinfo system
echo -e "${BLU}Using path: ${PROJECT_PATH} ${NCC}"
echo -e "${BLU}Creating user mailru ...${NCC}"
useradd -m -c "User for web-sysinfo" $USERNAME
passwd -d $USERNAME
#------------------------------------------------------------------------------------------------------------
# Locate TCPDUMP and TIMEOUT
c1=$(whereis tcpdump | awk -F " " '{ print $2 }')
c2=$(whereis timeout | awk -F " " '{ print $2 }')
cs=${SCRIPTS_DIR}/*
#------------------------------------------------------------------------------------------------------------
# Added sudo rules to /etc/sudoers for sysinfo user
echo -e "${BLU}Trying to add record to /etc/sudoers ...${NCC}"
printf "\n# User for web-sysinfo [!]\n ${USERNAME} ALL=NOPASSWD: $c1, $c2, $cs\n" >> /etc/sudoers
if [ $? != "0" ]; then
	echo -e "${RED}Couldn't change file: /etc/sudoers${NCC}"
fi
#------------------------------------------------------------------------------------------------------------
# Prepare directories for scripts and web-pages
echo -e "${BLU}Starting to copy scripts to ${SCRIPTS_DIR} ...${NCC}"
mkdir -p $SCRIPTS_DIR/data
mkdir -p /var/www/html/sysinfo
touch $INI_CONFIG
#------------------------------------------------------------------------------------------------------------
# [1] LOADAVG
sudo cp -f $PROJECT_PATH/loadavg.sh $SCRIPTS_DIR/loadavg.sh
printf "loadavg=${SCRIPTS_DIR}/loadavg.sh\n" >> $INI_CONFIG
# [2] IOSTAT
sudo cp -f $PROJECT_PATH/iostat.sh $SCRIPTS_DIR/iostat.sh
printf "iostat=\"cat ${SCRIPTS_DIR}/data/print_iostat\"\n" >> $INI_CONFIG
# [3] NETINF
sudo cp -f $PROJECT_PATH/netinf.sh $SCRIPTS_DIR/netinf.sh
printf "netinf=\"cat ${SCRIPTS_DIR}/data/print_netinf\"\n" >> $INI_CONFIG
# [4] TOPTLK
touch print_toptlk.txt
sudo cp -f $PROJECT_PATH/dpkt_test.py $SCRIPTS_DIR/dpkt_test.py
sudo cp -f $PROJECT_PATH/print_toptlk.txt $SCRIPTS_DIR/print_toptlk.txt
sudo cp -f $SCRIPTS_DIR/print_toptlk.txt $SCRIPTS_DIR/data/print_toptlk.txt
printf "toptlk=\"cat ${SCRIPTS_DIR}/data/print_toptlk.txt\"\n" >> $INI_CONFIG
# [5] NETCON
sudo cp -f $PROJECT_PATH/netcon.sh $SCRIPTS_DIR/netcon.sh
printf "netcon=\"cat ${SCRIPTS_DIR}/data/print_netcon\"\n" >> $INI_CONFIG
# [6] CPUINF
sudo cp -f $PROJECT_PATH/cpuinf.sh $SCRIPTS_DIR/cpuinf.sh
printf "cpuinf=\"cat ${SCRIPTS_DIR}/data/print_cpuinf\"\n" >> $INI_CONFIG
# [7] DISKST
sudo cp -f $PROJECT_PATH/diskst.sh $SCRIPTS_DIR/diskst.sh
printf "diskst=\"cat ${SCRIPTS_DIR}/data/print_diskst\"\n" >> $INI_CONFIG
# [E]
chown -R sysinfo:sysinfo $SCRIPTS_DIR/
chmod +x $SCRIPTS_DIR/*
#------------------------------------------------------------------------------------------------------------
# Crontab
echo -e "${BLU}Adding crontab for ${USERNAME} ...${NCC}"
crontab -l -u $USERNAME | cat - $PROJECT_PATH/automatic.cron | crontab -u $USERNAME -
#------------------------------------------------------------------------------------------------------------
# Setup scripts with special files
echo -e "${BLU}Prepare scripts ...${NCC}"
sudo $SCRIPTS_DIR/netinf.sh $SCRIPTS_DIR/data/curr_netinf
#------------------------------------------------------------------------------------------------------------
echo -e "${BLU}Installing tools, apache2+php and nginx ...${NCC}"
apt install -y sysstat elinks apache2 libapache2-mod-php
systemctl stop apache2
apt install -y nginx
sudo apt install -y python2.7
sudo apt install -y python-pip
sudo pip install dpkt
#------------------------------------------------------------------------------------------------------------
echo -e "${BLU}Starting to copy configuration files${NCC}"
cp -f $PROJECT_PATH/nginx-default.conf /etc/nginx/sites-enabled/default
cp -f $PROJECT_PATH/apache-ports.conf /etc/apache2/ports.conf
cp -f $PROJECT_PATH/apache-default.conf /etc/apache2/sites-enabled/000-default.$
cp -f $PROJECT_PATH/index.html /var/www/html/index.html
cp -f $PROJECT_PATH/index.php /var/www/html/index.php
cp -f $PROJECT_PATH/phpinfo.php /var/www/html/phpinfo.php
cp -f $PROJECT_PATH/sysinfo.php /var/www/html/sysinfo/index.php
#------------------------------------------------------------------------------------------------------------
sed -i "1 i <?php \$iniFile=\"${INI_CONFIG}\"; \$updateTime=${UPD_TIME}; ?>" /var/www/html/sysinfo/index.php
#------------------------------------------------------------------------------------------------------------
echo -e "${BLU}Restarting servers ... ${NCC}"
systemctl start apache2
systemctl restart nginx
#------------------------------------------------------------------------------------------------------------
# Restart scripts to collect inforamation from setup
echo -e "${BLU}Restarting scripts ... ${NCC}"
sudo $SCRIPTS_DIR/iostat.sh $SCRIPTS_DIR/data/print_iostat 
#sudo $SCRIPTS_DIR/data/print_cpuinf
sudo $SCRIPTS_DIR/netinf.sh
#sudo $SCRIPTS_DIR/toptlk.sh $SCRIPTS_DIR/data/print_toptlk &
sudo $SCRIPTS_DIR/netcon.sh
sudo $SCRIPTS_DIR/diskst.sh
sudo python $SCRIPTS_DIR/dpkt_test.py
sudo cp -f $SCRIPTS_DIR/print_toptlk.txt $SCRIPTS_DIR/data/print_toptlk.txt #$SCRIPTS_DIR/data/print_toptlk &
#------------------------------------------------------------------------------------------------------------
netstat -nlpt
echo -e "${BLU}END OF SCRIPT${NCC}\n"
#------------------------------------------------------------------------------------------------------------
exit 0
