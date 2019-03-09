# port-relay-bashscript
A bash script for port relay.

# Only relay single port or multiple port.
mode 0 is single port relay mode,can relay only 1 port;mode 1 is multiple port relay mode,can realy many port.but,all of this relay only the same port between localhost and remote host.
## For single port mode
only 1 port can been relay
## For multiple port mode
many port can been relay.
## check out iptables NAT rules
iptables -t nat -vnL POSTROUTING
iptables -t nat -vnL PREROUTING
## delet iptables NAT rules
iptables -t nat -D POSTROUTING 1
iptables -t nat -D PREROUTING 1
