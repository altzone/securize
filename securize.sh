#/bin/bash




echo "###############################################
Securisation du serveur $HOSTNAME
###############################################"
echo 
echo -e "\e[4mVerification système :\e[0m"
echo -n "
- Fail2Ban ...................................... "
if [[ `dpkg -l | grep fail2ban | grep ii` ]]; then
	if [[ `ps afx | grep fail2ban | grep -v grep` ]]; then
       		echo -e "\e[92mOK\e[0m"
		echo "  - fail2ban installé et tourne"
	else
		echo -e "\e[93mWARN\e[0m"
		echo "  - fail2ban installé mais n'est pas lancé"
		echo -n "    Lancement => "
		/etc/init.d/fail2ban restart &> /dev/null && echo -e "\e[92mOK\e[0m" || echo -e "\e[91mFAIL\e[0m"
	fi
else
        echo -e "\e[93mWARN\e[0m"
	echo -en "  - fail2ban non installé ... \e[1minstallation =>\e[0m "
		apt-get -qq update && apt-get -qq -y install fail2ban && echo -e "\e[92mOK\e[0m" || echo -e "\e[91mFAIL\e[0m"		
	echo -n "    Lancement => "
	/etc/init.d/fail2ban restart &> /dev/null && echo -e "\e[92mOK\e[0m" || echo -e "\e[91mFAIL\e[0m"
fi

echo -n "
- SSH bind Listen : ............................. "
port=`cat /etc/ssh/sshd_config | grep Port | awk {'print $2'}`
if [[ `lsof -i :$port -P -n | grep sshd |grep LISTEN | grep \*` ]]; then
	echo -e "\e[93mWARN\e[0m"
	echo -e "\n    o Attention ! SSH ecoute sur :\n`lsof -i :$port -P -n | grep sshd |grep LISTEN | sed s/:/" "/g | awk {'print "      -"$5" => "$9'}` Port: $port"
	echo "    => Voulez-vous que SSH ecoute sur l'interface privé? (Y/n)"
read yno
case $yno in

        [yY] | [yY][Ee][Ss] )
                echo -en "  - Mise à jour de la configuration SSH \e[1m =>\e[0m ";
		prive=`ip add sh | grep 10.10.255.255 | sed s/"\/"/" "/g | awk {'print $2'}`
		echo "ListenAddress $prive" >> /etc/ssh/sshd_config && /etc/init.d/ssh restart &> /dev/null && echo -e "\e[92mOK\e[0m" || echo -e "\e[91mFAIL\e[0m"
                echo
		echo
		;;

        [nN] | [n|N][O|o] )
                ;;
        *) echo "erreur";
            ;;
esac
else
	echo -e "\e[92mOK\e[0m"
	echo -e "    o SSH ecoute sur :\n`lsof -i :22 -P -n | grep sshd |grep LISTEN | sed s/:/" "/g | awk {'print "      -"$5" => "$9'}` Port: $port"
fi

echo -n "
- SNMP bind Listen : ............................ "


if [[ `lsof -i :161 -P -n | grep snmpd | grep \*` ]]; then
	echo -e "\e[93mWARN\e[0m"
	echo -e "\n    o Attention ! SNMP ecoute sur :\n`lsof -i :161 -P -n | grep snmpd | sed s/:/" "/g | awk {'print "      -"$5" => "$9'}`"
        echo "    => Voulez-vous que SNMP ecoute sur l'interface privé? (Y/n)"
read yno
case $yno in

        [yY] | [yY][Ee][Ss] )
                echo -en "  - Mise à jour de la configuration SNMP \e[1m =>\e[0m "
prive=`ip add sh | grep 10.10.255.255 | sed s/"\/"/" "/g | awk {'print $2'}`
		echo "export MIBDIRS=/usr/share/snmp/mibs
SNMPDRUN=yes
SNMPDOPTS='-LS 0-4 d -Lf /dev/null -u snmp -I -smux -p /var/run/snmpd.pid $prive'
TRAPDRUN=no
TRAPDOPTS='-Lsd -p /var/run/snmptrapd.pid'
" > /etc/default/snmpd
/etc/init.d/snmpd restart &> /dev/null && echo -e "\e[92mOK\e[0m" || echo -e "\e[91mFAIL\e[0m"
		echo
		echo
		;;

        [nN] | [n|N][O|o] )
		echo -en "  - Mise à jour de la configuration SNMP (verbose) \e[1m =>\e[0m "
		[[ `grep "10.10." /etc/default/snmpd` ]] && ip=`ip add sh | grep 10.10.255.255 | sed s/"\/"/" "/g | awk {'print $2'}` || ip=""
		echo "export MIBDIRS=/usr/share/snmp/mibs
SNMPDRUN=yes
SNMPDOPTS='-LS 0-4 d -Lf /dev/null -u snmp -I -smux -p /var/run/snmpd.pid $ip'
TRAPDRUN=no
TRAPDOPTS='-Lsd -p /var/run/snmptrapd.pid'
" > /etc/default/snmpd
		/etc/init.d/snmpd restart &> /dev/null && echo -e "\e[92mOK\e[0m" || echo -e "\e[91mFAIL\e[0m"

		;;
        *) echo "erreur";
            ;;
esac

else
	echo -e "\e[92mOK\e[0m"
	echo -e "    o SNMP ecoute sur :\n`lsof -i :161 -P -n | grep snmpd | sed s/:/" "/g | awk {'print "      -"$5" => "$9'}`"
	if [[ ! `grep "\-LS 0\-4" /etc/default/snmpd` ]]; then
	echo -en "  - Mise à jour de la configuration SNMP (verbose) \e[1m =>\e[0m "
[[ `grep "10.10." /etc/default/snmpd` ]] && ip=`ip add sh | grep 10.10.255.255 | sed s/"\/"/" "/g | awk {'print $2'}` || ip=""
echo "export MIBDIRS=/usr/share/snmp/mibs
SNMPDRUN=yes
SNMPDOPTS='-LS 0-4 d -Lf /dev/null -u snmp -I -smux -p /var/run/snmpd.pid $ip'
TRAPDRUN=no
TRAPDOPTS='-Lsd -p /var/run/snmptrapd.pid'
" > /etc/default/snmpd
/etc/init.d/snmpd restart &> /dev/null && echo -e "\e[92mOK\e[0m" || echo -e "\e[91mFAIL\e[0m"
 fi

 fi

echo
echo
rm $0
exit 0

