#!/bin/bash

sudo touch /etc/NetworkManager/conf.d/00-macrandomize.conf

echo "[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=stable
ethernet.cloned-mac-address=stable
connection.stable-id=${CONNECTION}/${BOOT}
#use random IPv6 addresses per session / don't leak MAC via IPv6 (cf. RFC 4941):
ipv6.ip6-privacy=2" | sudo tee /etc/NetworkManager/conf.d/00-macrandomize.conf


sudo touch /etc/NetworkManager/conf.d/dhclient.conf 

echo "[main]
dhcp=dhclient" | sudo tee /etc/NetworkManager/conf.d/dhclient.conf

sudo touch /etc/NetworkManager/dispatcher.d/pre-up.d/00_hostname

echo "#!/bin/bash
set -e -o pipefail

if [ -f "/rw/config/protected-files.d/protect_hostname.txt" ] && rand="$RANDOM" && mv "/etc/hosts.lock" "/etc/hosts.lock.$rand" ; then
	name="PC-$rand"
	echo "$name" > /etc/hostname
	hostname "$name"
	#NOTE: NetworkManager may set it again after us based on DHCP or /etc/hostname, cf. `man NetworkManager.conf` @hostname-mode
	
	#from /usr/lib/qubes/init/qubes-early-vm-config.sh
	if [ -e /etc/debian_version ]; then
            ipv4_localhost_re="127\.0\.1\.1"
        else
            ipv4_localhost_re="127\.0\.0\.1"
        fi
        sed -i "s/^\($ipv4_localhost_re\(\s.*\)*\s\).*$/\1${name}/" /etc/hosts
        sed -i "s/^\(::1\(\s.*\)*\s\).*$/\1${name}/" /etc/hosts
fi
exit 0" | sudo tee /etc/NetworkManager/dispatcher.d/pre-up.d/00_hostname


echo "net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8192
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.core.optmem_max = 65536
net.ipv4.tcp_rmem = 4096 1048576 2097152
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_timestamps = 0
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr
net.ipv4.ip_local_port_range = 30000 65535
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.icmp_echo_ignore_all = 1
net.ipv6.icmp.echo_ignore_all = 1" | sudo tee /etc/sysctl.d/99-sysctl.conf

sudo sysctl --system
