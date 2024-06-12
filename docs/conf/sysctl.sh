#!/usr/bin/env -S bash -e

cat="$( command -v cat )"

[[ ! -d '/etc/sysctl.d' ]] && { echo "Directory '/etc/sysctl.d' not found!"; exit 1; }

${cat} > '/etc/sysctl.d/00-sysctl.local.conf' <<EOF
# NET:Core.
net.core.somaxconn                      = 65536
net.core.rmem_default                   = 65536
net.core.rmem_max                       = 16777216
net.core.wmem_default                   = 65536
net.core.wmem_max                       = 16777216

# NET:IPv6.
net.ipv6.conf.all.disable_ipv6          = 1
net.ipv6.conf.default.disable_ipv6      = 1
net.ipv6.conf.lo.disable_ipv6           = 1

# NET:TCP.
net.ipv4.tcp_no_metrics_save            = 1
net.ipv4.tcp_syncookies                 = 0
net.ipv4.tcp_timestamps                 = 1
net.ipv4.tcp_fastopen                   = 1
net.ipv4.tcp_slow_start_after_idle      = 0
net.ipv4.tcp_congestion_control         = bbr

# FS.
fs.file-max                             = 500000
fs.inotify.max_user_watches             = 524288
EOF

exit 0
