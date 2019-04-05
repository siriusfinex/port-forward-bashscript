# Port-relay-bashscript
A bash script for port relay.

# One-button to run script  
For Debian/Ubuntu:  

```
wget -qO- https://raw.githubusercontent.com/siriusfinex/port-forward-bashscript/master/port-forward-debian.sh | bash
```

## Only relay single same port and multiple same ports.
"mode 0" is single port relay mode,can relay only 1 port;  
"mode 1" is multiple port relay mode,can realy a range of ports；   
but,all of this relay only the same port between localhost and remote host.
## For single port mode
only 1 port can been relay
## For multiple port mode
many port can been relay;  
"start port" mean is minimum relay port, "end port" mean is maximum relay port,  
For example,relay port is 100 to 1000,so "start port" is 100 and "end port" is 1000.
## Check iptables NAT rules
iptables -t nat -vnL POSTROUTING  
iptables -t nat -vnL PREROUTING
## Delete iptables NAT rules
iptables -t nat -D POSTROUTING 1  
iptables -t nat -D PREROUTING 1
