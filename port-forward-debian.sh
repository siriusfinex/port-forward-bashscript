#! /bin/bash

#! /bin/bash
#enable net.ipv4.ip_forward
ipv4_forward_str=$(sed -n '/^net.ipv4.ip_forward=1/'p /etc/sysctl.conf)
if [ "$ipv4_forward_str" == "net.ipv4.ip_forward=1" ]; then
        echo "net.ipv4.ip_forward=1 configure is right"
else
        echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p
fi

#choice relay mode and setting port relay
echo "Only same port can use this bashscript."
echo -n "local ip:" ; read local_ip && echo -n "remote ip:" ; read remote_ip
echo "mode 0 is single port forward;mode 1 is multiple port forward."
echo -n "mode:" ; read mode
if [ "$mode" == '0' ]; then
  echo -n "port:" ; read port
  iptables -t nat -A PREROUTING -p tcp --dport $port -j DNAT --to-destination $remote_ip:$port
  iptables -t nat -A PREROUTING -p udp --dport $port -j DNAT --to-destination $remoteip:$port
  iptables -t nat -A POSTROUTING -p udp -d $remote_ip --dport $port -j SNAT --to-source $local_ip
  iptables -t nat -A POSTROUTING -p tcp -d $remote_ip --dport $port -j SNAT --to-source $local_ip
elif [ "$mode" == '1' ]; then
  echo -n "start port:" ; read start_port && echo -n "end port:" ; read end_port
  iptables -t nat -A PREROUTING -p tcp -m tcp --dport $start_port:$end_port -j DNAT --to-destination $remote_ip:$start_port-$end_port
  iptables -t nat -A PREROUTING -p udp -m udp --dport $start_port:$end_port -j DNAT --to-destination $remote_ip:$start_port-$end_port
  iptables -t nat -A POSTROUTING -d $remote_ip -p tcp -m tcp --dport $start_port:$end_port -j SNAT --to-source $local_ip
  iptables -t nat -A POSTROUTING -d $remote_ip -p udp -m udp --dport $start_port:$end_port -j SNAT --to-source $local_ip
else
  echo "Failed,please read the tips,the mode value only 0 or 1"
fi

#save port forward rules to iptables
iptables-save > /etc/iptables.up.rules

#setting iptables autostart
iptables-save > /etc/iptables.up.rules
echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' > /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables
