# @package    MikroTik / RouterOS / RB941
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
/interface wireless security-profiles
add authentication-types=wpa2-psk mode=dynamic-keys name=security supplicant-identity="" wpa2-pre-shared-key="wifi-rb941"
/interface wireless
set [ find default-name="wlan1" ] band=2ghz-b/g/n channel-width=20/40mhz-XX country=russia4 disabled=no installation=indoor mode=ap-bridge security-profile=security ssid="GW-RB941" wps-mode=disabled
/ip pool
add name=dhcp ranges=192.168.88.10-192.168.88.254
/ip dhcp-server
add address-pool=dhcp interface=bridge1 name=dhcp1
/interface bridge port
add bridge=bridge1 interface=ether2
add bridge=bridge1 interface=ether3
add bridge=bridge1 interface=ether4
add bridge=bridge1 interface=wlan1
/ipv6 settings
set disable-ipv6=yes
/interface list member
add interface=ether1 list=WAN
add interface=bridge1 list=LAN
/ip address
add address=192.168.88.1/24 interface=bridge1 network=192.168.88.0
/ip dhcp-client
add interface=ether1
/ip dhcp-server network
add address=192.168.88.0/24 dns-server=192.168.88.1,1.1.1.1,1.0.0.1 domain=home.lan gateway=192.168.88.1 ntp-server=192.168.88.1
/ip dns
set allow-remote-requests=yes servers=1.1.1.1,1.0.0.1
/ip dns static
add address=192.168.88.1 name=gw.lan comment="LAN Gateway"
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
set name="GW-RB941"
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
