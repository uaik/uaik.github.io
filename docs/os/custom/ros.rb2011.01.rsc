# @package    MikroTik / RouterOS / RB2011.01
# @author     Kitsune Solar <mail@kitsune.solar>
# @copyright  2023 iHub.TO
# @license    MIT
# @version    0.1.0
# @link
# -------------------------------------------------------------------------------------------------------------------- #

/interface bridge
add name=bridge1
/interface list
add name=WAN
add name=LAN
/ip pool
add name=dhcp ranges=10.0.250.1-10.0.255.254
/ip dhcp-server
add address-pool=dhcp interface=bridge1 name=dhcp1
/interface bridge port
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3
add bridge=bridge1 interface=ether4
add bridge=bridge1 interface=ether5
add bridge=bridge1 interface=ether6
add bridge=bridge1 interface=ether7
add bridge=bridge1 interface=ether8
add bridge=bridge1 interface=ether9
add bridge=bridge1 interface=ether10
/ipv6 settings
set disable-ipv6=yes
/interface list member
add interface=ether1 list=WAN
add interface=bridge1 list=LAN
/ip address
add address=10.0.0.1/16 interface=bridge1 network=10.0.0.0
/ip dhcp-client
add interface=ether1
/ip dhcp-server lease
add address=10.0.1.1 mac-address=14:EB:B6:B3:28:90 comment="TL-SG1024DE-01"
add address=10.0.2.1 mac-address=14:EB:B6:63:C6:09 comment="TL-SG108E-01"
add address=10.0.2.2 mac-address=B4:B0:24:92:E4:60 comment="TL-SG108E-02"
add address=10.0.3.1 mac-address=50:FF:20:79:B6:38 comment="KN-3510-01"
add address=10.0.5.1 mac-address=14:DA:E9:B3:A6:F5 comment="PVE-CRAFT"
add address=10.0.5.2 mac-address=AA:0D:0D:85:9A:A3 comment="PVE-CRAFT-01"
add address=10.0.5.3 mac-address=96:AD:F4:C8:12:2C comment="PVE-CRAFT-02"
/ip dhcp-server network
add address=10.0.0.0/16 dns-server=10.0.0.1,1.1.1.1,1.0.0.1 domain=home.lan gateway=10.0.0.1 ntp-server=10.0.0.1
/ip dns
set allow-remote-requests=yes servers=1.1.1.1,1.0.0.1
/ip dns static
add address=10.0.0.1 name=gw01.lan comment="LAN Gateway 01"
/ip firewall filter
add action=accept chain=input connection-state=established,related,untracked comment="[ACCEPT] Established, Related, Untracked"
add action=drop chain=input connection-state=invalid comment="[DROP] Invalid"
add action=accept chain=input protocol=icmp comment="[ACCEPT] ICMP"
add action=accept chain=input dst-port=9090,22022 protocol=tcp comment="[ROS] WinBox and SSH"
add action=drop chain=input in-interface-list=!LAN comment="[DROP] All not coming from LAN"
add action=accept chain=forward ipsec-policy=in,ipsec comment="[ACCEPT] In IPsec policy"
add action=accept chain=forward ipsec-policy=out,ipsec comment="[ACCEPT] Out IPsec policy"
add action=fasttrack-connection chain=forward connection-state=established,related comment="[ROS] FastTrack"
add action=accept chain=forward connection-state=established,related,untracked comment="[ROS] FastTrack"
add action=drop chain=forward connection-state=invalid comment="[DROP] Invalid"
add action=drop chain=forward connection-nat-state=!dstnat connection-state=new in-interface-list=WAN comment="[DROP] All from WAN not DSTNATed"
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN
add action=dst-nat chain=dstnat dst-port=60511 protocol=tcp to-addresses=10.0.5.1 to-ports=8006 comment="PVE-CRAFT / ProxMox"
add action=dst-nat chain=dstnat dst-port=60521 protocol=tcp to-addresses=10.0.5.2 to-ports=22122 comment="PVE-CRAFT / 01 / SSH"
add action=dst-nat chain=dstnat dst-port=60522 protocol=tcp to-addresses=10.0.5.2 to-ports=8384 comment="PVE-CRAFT / 01 / Syncthing"
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh port=22022
set api disabled=yes
set winbox port=9090
set api-ssl disabled=yes
/lcd
set enabled=no
/system clock
set time-zone-name=Europe/Moscow
/system identity
set name="GW-01"
/system ntp client
set enabled=yes
/system ntp server
set enabled=yes manycast=yes multicast=yes
/system ntp client servers
add address=time.cloudflare.com
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=none
/tool mac-server ping
set enabled=no
/user
set [find name="admin"] password="cDFymu2aML"
