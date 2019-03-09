#! /bin/bash
#enable firewall ipv4 port relay
str=$(sed -n '/^net.ipv4.ip_forward=1/'p /etc/sysctl.conf)

if [ "$str" == "net.ipv4.ip_forward=1" ]; then
        echo "net.ipv4.ip_forward=1 setting right"
else
        echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p
fi


#choice relay mode and setting port relay
echo "Only same port can use this bashscript."
echo -n "local ip:" ; read localip && echo -n "remote ip:" ; read remoteip
echo "mode 0 is single port,mode 1 is multiple port."
echo -n "mode:" ; read mode
if [ "$mode" == '0' ]; then
  echo -n "port:" ; read port
  iptables -t nat -A PREROUTING -p tcp --dport $port -j DNAT --to-destination $remoteip:$port
  iptables -t nat -A PREROUTING -p udp --dport $port -j DNAT --to-destination $remoteip:$port
  iptables -t nat -A POSTROUTING -p udp -d $remoteip --dport $port -j SNAT --to-source $localip
  iptables -t nat -A POSTROUTING -p tcp -d $remoteip --dport $port -j SNAT --to-source $localip
elif [ "$mode" == '1' ]; then
  echo -n "start port:" ; read startport && echo -n "end port:" ; read endport
  iptables -t nat -A PREROUTING -p tcp -m tcp --dport $startport:$endport -j DNAT --to-destination $remoteip:$startport-$endport
  iptables -t nat -A PREROUTING -p udp -m udp --dport $startport:$endport -j DNAT --to-destination $remoteip:$startport-$endport
  iptables -t nat -A POSTROUTING -d $remoteip -p tcp -m tcp --dport $startport:$endport -j SNAT --to-source $localip
  iptables -t nat -A POSTROUTING -d $remoteip -p udp -m udp --dport $startport:$endport -j SNAT --to-source $localip
else
  echo "Please read the tips"
fi

#save port relay rules to iptables
iptables-save > /etc/iptables.up.rules

#setting iptables autostart
iptables-save > /etc/iptables.up.rules
echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' > /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables
