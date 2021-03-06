#!/bin/bash
#
# Generates lock script, must be run as root
#
# Usage :
#	$0 <ssh_user>
#
# Examples
#	$0 azadmin
#
#
# Requirements :
#	must be run as root
#	
# Return codes
#	1 : invalid arguments
#	2 : sshpass utility not found (or uninstallable)
#

LOCK_SCRIPT=/tmp/lock.sh
SSHD_CONFIG=/etc/ssh/sshd_config
USER=${1:-azadmin}


cat > $LOCK_SCRIPT <<DELIM
 #!/bin/bash
 sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/g' $SSHD_CONFIG
 [ service ssh status &> /dev/null ]   &&  service ssh restart
 [ service sshd status &> /dev/null ]  &&  service sshd restart
DELIM

chmod +600 $LOCK_SCRIPT

SUDOERS=/etc/sudoers
cat /etc/sudoers > /tmp/sudoers

echo "Cmnd_Alias LOCK_SCRIPT=/usr/bin/bash $LOCK_SCRIPT" >> $SUDOERS
echo "$USER ALL=(root) NOPASSWD:LOCK_SCRIPT " >> $SUDOERS
echo 'Defaults!LOCK_SCRIPT !requiretty' >> $SUDOERS