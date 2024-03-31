# @package    MikroTik / RouterOS / 10.2.0.0
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link
# -------------------------------------------------------------------------------------------------------------------- #
# Set MAC:
# /interface ethernet set [ find default-name="ether1" ] mac-address="00:00:00:00:00:00"
# -------------------------------------------------------------------------------------------------------------------- #

:local rosAdminPassword "cDFymu2aML"
:local rosBridgeName "bridge1"
:local rosRouterName "GW01"
:local rosGwDomain "gw01.lan"
:local rosNwDomain "home.lan"
:local rosIcmpKnockSize 100

# -------------------------------------------------------------------------------------------------------------------- #

/interface bridge
add name="$rosBridgeName"

/interface list
add name=WAN
add name=LAN

/interface bridge port
:for i from=2 to=5 do={ add bridge="$rosBridgeName" interface=("ether" . $i) }

/interface list member
add interface=ether1 list=WAN
add interface="$rosBridgeName" list=LAN

/ip pool
add name=dhcp ranges=10.2.200.1-10.2.200.254

/ip dhcp-server
add address-pool=dhcp interface="$rosBridgeName" name=dhcp1

/ip neighbor discovery-settings
set discover-interface-list=LAN

/ip address
add address=10.2.0.1/16 interface="$rosBridgeName" network=10.2.0.0

/ip dhcp-client
add interface=ether1

/ip dhcp-server lease
# add address=10.2.0.40 mac-address=00:00:00:00:00:00 comment="SERVER01"

/ip dhcp-server network
add address=10.2.0.0/16 dns-server=10.2.0.1 domain="$rosNwDomain" gateway=10.2.0.1 ntp-server=10.2.0.1

/ip dns
set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8,77.88.8.8

/ip dns static
add address=10.2.0.1 name="$rosGwDomain"

/ip firewall filter
add action=accept chain=input connection-state=established,related,untracked \
  comment="[ROS] Established, Related, Untracked"
add action=drop chain=input connection-state=invalid \
  comment="[ROS] Invalid"
add action=add-src-to-address-list address-list="AdminCP" address-list-timeout=30m chain=input in-interface-list=WAN \
  packet-size=($rosIcmpKnockSize + 28) protocol=icmp \
  comment="[ROS] ICMP port knocking for AdminCP"
add action=accept chain=input protocol=icmp \
  comment="[ROS] ICMP"
add action=accept chain=input dst-port=9090,22022 protocol=tcp src-address-list="AdminCP" \
  comment="[ROS] WinBox and SSH"
add action=drop chain=input in-interface-list=!LAN \
  comment="[ROS] All not coming from LAN"
add action=accept chain=forward ipsec-policy=in,ipsec \
  comment="[ROS] In IPsec policy"
add action=accept chain=forward ipsec-policy=out,ipsec \
  comment="[ROS] Out IPsec policy"
add action=fasttrack-connection chain=forward connection-state=established,related \
  comment="[ROS] FastTrack"
add action=accept chain=forward connection-state=established,related,untracked \
  comment="[ROS] FastTrack"
add action=drop chain=forward connection-state=invalid \
  comment="[ROS] Invalid"
add action=drop chain=forward connection-nat-state=!dstnat connection-state=new in-interface-list=WAN \
  comment="[ROS] All from WAN not DSTNATed"

/ip firewall nat
add action=masquerade chain=srcnat ipsec-policy=out,none out-interface-list=WAN \
  comment="[ROS] Masquerade"

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
set name="$rosRouterName"

/system ntp client
set enabled=yes

/system ntp server
set enabled=yes manycast=yes multicast=yes

/system ntp client servers
add address="0.ru.pool.ntp.org"
add address="1.ru.pool.ntp.org"
add address="time.google.com"
add address="time.cloudflare.com"

/tool bandwidth-server
set enabled=no

/tool mac-server
set allowed-interface-list=none

/tool mac-server ping
set enabled=no

/user
set [find name="admin"] password="$rosAdminPassword"
