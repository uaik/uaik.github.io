# @package    MikroTik / RouterOS / 10.2.0.0
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link
# -------------------------------------------------------------------------------------------------------------------- #

:local bridgeName "bridge1"
:local adminPassword "cDFymu2aML"
:local routerName "GW01"
:local dnsRouter "gw01.lan"
:local dhcpDomain "home.lan"
:local netBase 10.2
:local icmpKnockSize 100

/interface bridge
add name=$bridgeName

/interface list
add name=WAN
add name=LAN

/interface bridge port
:for i from=2 to=5 do={ add bridge=$bridgeName interface=("ether" . $i) }

/interface list member
add interface=ether1 list=WAN
add interface=$bridgeName list=LAN

/ip pool
add name=dhcp ranges=$netBase.200.1-$netBase.200.254

/ip dhcp-server
add address-pool=dhcp interface=$bridgeName name=dhcp1

/ip neighbor discovery-settings
set discover-interface-list=LAN

/ip address
add address=$netBase.0.1/16 interface=$bridgeName network=$netBase.0.0

/ip dhcp-client
add interface=ether1

/ip dhcp-server lease
# add address=$netBase.1.1 mac-address=11:11:11:11:11:11 comment="SERVER01"

/ip dhcp-server network
add address=$netBase.0.0/16 dns-server=$netBase.0.1 domain=$dhcpDomain gateway=$netBase.0.1 ntp-server=$netBase.0.1

/ip dns
set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8,77.88.8.8

/ip dns static
add address=$netBase.0.1 name=$dnsRouter

/ip firewall filter
add action=accept chain=input connection-state=established,related,untracked comment="[ACCEPT] Established, Related, Untracked"
add action=drop chain=input connection-state=invalid comment="[DROP] Invalid"
add action=add-src-to-address-list address-list="AdminCP" address-list-timeout=30m chain=input in-interface-list=WAN packet-size=($icmpKnockSize + 28) protocol=icmp comment="ICMP port knocking to AdminCP"
add action=accept chain=input protocol=icmp comment="[ACCEPT] ICMP"
add action=accept chain=input dst-port=9090,22022 protocol=tcp src-address-list="AdminCP" comment="[ROS] WinBox and SSH"
add action=drop chain=input in-interface-list=!LAN comment="[DROP] All not coming from LAN"
add action=accept chain=forward ipsec-policy=in,ipsec comment="[ACCEPT] In IPsec policy"
add action=accept chain=forward ipsec-policy=out,ipsec comment="[ACCEPT] Out IPsec policy"
add action=fasttrack-connection chain=forward connection-state=established,related comment="[ROS] FastTrack"
add action=accept chain=forward connection-state=established,related,untracked comment="[ROS] FastTrack"
add action=drop chain=forward connection-state=invalid comment="[DROP] Invalid"
add action=drop chain=forward connection-nat-state=!dstnat connection-state=new in-interface-list=WAN comment="[DROP] All from WAN not DSTNATed"

/ip firewall nat
add action=masquerade chain=srcnat ipsec-policy=out,none out-interface-list=WAN comment="Masquerade"

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh port=22022
set api disabled=yes
set winbox port=9090
set api-ssl disabled=yes

/system clock
set time-zone-name=Europe/Moscow

/system identity
set name=$routerName

/system ntp client
set enabled=yes

/system ntp server
set enabled=yes manycast=yes multicast=yes

/system ntp client servers
add address=0.ru.pool.ntp.org
add address=1.ru.pool.ntp.org
add address=time.google.com
add address=time.cloudflare.com

/tool bandwidth-server
set enabled=no

/tool mac-server
set allowed-interface-list=none

/tool mac-server ping
set enabled=no

/user
set [find name="admin"] password=$adminPassword
