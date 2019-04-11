#! /bin/bash
#enable net.ipv4.ip_forward
sed -n '/^net.ipv4.ip_forward=1/'p /etc/sysctl.conf | grep -q "net.ipv4.ip_forward=1"
if [ $? -eq 0 ]; then
    echo "yes"
else
    echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p
fi

#choice relay mode and setting port forward
echo "Only same port can use this bashscript."

#get local_ip
local_ip=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1 | grep -Ev '(^127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.1[6-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.2[0-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.3[0-1]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^192\.168\.[0-9]{1,3}\.[0-9]{1,3}$)')
if [ "x${extip}" = "x" ]; then
  local_ip=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1 )
fi
echo "local ip: $local_ip"

#echo -n "local ip:" ; read local_ip
echo -n "remote ip:" ; read remote_ip
echo "mode 0 is single port forward;mode 1 is multiple port forward."
echo -n "mode:" ; read mode
if [ "$mode" == '0' ]; then
  echo -n "port:" ; read single_port
  port1=$single_port
  port2=$single_port
elif [ "$mode" == '1' ]; then
  echo -n "start port:" ; read start_port && echo -n "end port:" ; read end_port
  port1=$start_port:$end_port
  port2=$start_port-$end_port
else
  echo "Failed,please read the tips,the mode value only 0 or 1"
fi

#check iptables history port forward rules and add new port forward.
iptables -t nat -vnL PREROUTING | grep "tcp" | grep "$remote_ip" | grep "$port1"  | grep -q "$port2"
if [ $? -eq 0 ] ; then
 	echo "yes"
else
	iptables -t nat -A PREROUTING -p tcp -m tcp --dport $port1 -j DNAT --to-destination $remote_ip:$port2
fi

iptables -t nat -vnL PREROUTING | grep "udp" | grep "$remote_ip" | grep "$port1" | grep -q "$port2"
if [ $? -eq 0 ] ; then
 	echo "yes"
else
	iptables -t nat -A PREROUTING -p udp -m udp --dport $port1 -j DNAT --to-destination $remote_ip:$port2
fi

iptables -t nat -vnL POSTROUTING | grep "tcp" | grep "$port1" | grep -q "$local_ip"
if [ $? -eq 0 ] ; then
 	echo "yes"
else
	iptables -t nat -A POSTROUTING -p tcp -d $remote_ip --dport $port1 -j SNAT --to-source $local_ip
fi

iptables -t nat -vnL POSTROUTING | grep "udp" | grep "$port1" | grep -q "$local_ip"
if [ $? -eq 0 ] ; then
 	echo "yes"
else
	iptables -t nat -A POSTROUTING -p udp -d $remote_ip --dport $port1 -j SNAT --to-source $local_ip
fi

#save port forward rules to iptables
iptables-save > /etc/iptables.up.rules

#setting iptables autostart
iptables-save > /etc/iptables.up.rules
echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' > /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables
