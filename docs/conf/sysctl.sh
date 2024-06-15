#!/usr/bin/env -S bash -e

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Apps.
  cat=$( command -v cat )

  # Run.
  sysctl
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSCTL.
# -------------------------------------------------------------------------------------------------------------------- #

sysctl() {
  local d='/etc/sysctl.d'; [[ ! -d "${d}" ]] && exit 1
  local f='00-sysctl.local.conf'

  ${cat} > "${d}/${f}" <<EOF
# -------------------------------------------------------------------------------------------------------------------- #
# Kernel.
# -------------------------------------------------------------------------------------------------------------------- #

# Enable ExecShield protection.
# 2 enables ExecShield by default unless applications bits are set to disabled.
# Uncomment on systems without NX/XD protections.
# Check with: dmesg | grep --color '[NX|DX]*protection'.
#kernel.exec-shield = 2

# Enable ASLR.
# Turn on protection and randomize stack, vdso page and mmap + randomize brk base address.
kernel.randomize_va_space = 2

# Controls the System Request debugging functionality of the kernel.
kernel.sysrq = 0

# Controls whether core dumps will append the PID to the core filename.
# Useful for debugging multi-threaded applications.
kernel.core_uses_pid = 1

# Restrict access to kernel address.
# Kernel pointers printed using %pK will be replaced with 0’s regardless of privileges.
kernel.kptr_restrict = 2

# Ptrace protection using Yama.
#   - 0 (classic): allows any process to trace any other process under the same UID.
#   - 1 (restricted): only a parent process can be debugged.
#   - 2 (admin-only): only admins can use ptrace (CAP_SYS_PTRACE capability required).
#   - 3 (no attach): disables ptrace completely, reboot is required to re-enable ptrace.
# The general recommendation for this setting is:
#   - if you do not need to debug programs, set it to 3.
#   - if you need to debug programs (e.g., GDB, LLDB, strace), set it to 1.
# Setting it to 3 will also break LXC v6+ procfs emulation for unprivileged containers.
#   (see GitHub issue https://github.com/lxc/lxcfs/issues/636)
kernel.yama.ptrace_scope = 3

# Restrict kernel logs to root only.
kernel.dmesg_restrict = 1

# Restrict BPF JIT compiler to root only.
kernel.unprivileged_bpf_disabled = 1

# Disables kexec as it can be used to livepatch the running kernel.
kernel.kexec_load_disabled = 1

# Disable unprivileged user namespaces to decrease attack surface.
kernel.unprivileged_userns_clone = 0

# Disable the loading of kernel modules.
# This can be used to prevent runtime insertion of malicious modules.
# Could break the system if enabled within sysctl.conf.
# Consider setting this manually after system is up.
# sysctl -w kernel.modules_disabled=1
#kernel.modules_disabled = 1

# Allow for more PIDs.
# This value can be up to:
#   - 32768 (2^15) on a 32-bit system.
#   - 4194304 (2^22) on a 64-bit system.
kernel.pid_max = 4194304

# Reboot machine after kernel panic.
#kernel.panic = 10

# Restrict perf subsystem usage.
kernel.perf_event_paranoid = 3
kernel.perf_cpu_time_max_percent = 1
kernel.perf_event_max_sample_rate = 1

# Prevent unprivileged attackers from loading vulnerable line disciplines with the TIOCSETD ioctl.
dev.tty.ldisc_autoload = 0

# -------------------------------------------------------------------------------------------------------------------- #
# File System.
# -------------------------------------------------------------------------------------------------------------------- #

# Disallow core dumping by SUID/SGID programs.
fs.suid_dumpable = 0

# Protect the creation of hard links.
# One of the following conditions must be fulfilled:
#   - the user can only link to files that he or she owns.
#   - the user must first have read and write access to a file, that he/she wants to link to.
fs.protected_hardlinks = 1

# Protect the creation of symbolic links.
# One of the following conditions must be fulfilled:
#   - the process following the symbolic link is the owner of the symbolic link.
#   - the owner of the directory is also the owner of the symbolic link.
fs.protected_symlinks = 1

# Enable extended FIFO protection.
fs.protected_fifos = 2

# Similar to protected_fifos, but it avoids writes to an attacker-controlled regular file.
fs.protected_regular = 2

# Increase system file descriptor limit.
# This value can be up to:
#   - 2147483647 (0x7fffffff) on a 32-bit system.
#   - 9223372036854775807 (0x7fffffffffffffff) on a 64-bit system.
# Be aware that the Linux kernel documentation suggests that inode-max should be 3-4 times larger than this value.
fs.file-max = 9223372036854775807

# Increase the amount of files that can be watched.
# Each file watch handle takes 1080 bytes.
# Up to 540 MiB of memory will be consumed if all 524288 handles are used.
fs.inotify.max_user_watches = 524288

# -------------------------------------------------------------------------------------------------------------------- #
# Virtualization.
# -------------------------------------------------------------------------------------------------------------------- #

# Do not allow mmap in lower addresses.
vm.mmap_min_addr = 65536

# Improve mmap ASLR effectiveness.
vm.mmap_rnd_bits = 32
vm.mmap_rnd_compat_bits = 16

# Prevent unprivileged users from accessing userfaultfd.
# Restricts syscall to the privileged users or the CAP_SYS_PTRACE capability.
vm.unprivileged_userfaultfd = 0

# -------------------------------------------------------------------------------------------------------------------- #
# Networking.
# -------------------------------------------------------------------------------------------------------------------- #

# Increase the maximum length of processor input queues.
net.core.netdev_max_backlog = 250000

# Enable BPF JIT hardening for all users.
# This trades off performance, but can mitigate JIT spraying.
net.core.bpf_jit_harden = 2

# Increase TCP max buffer size setable using setsockopt().
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608
net.core.rmem_default = 8388608
net.core.wmem_default = 8388608
#net.core.optmem_max = 40960

# -------------------------------------------------------------------------------------------------------------------- #
# IPv4: Networking.
# -------------------------------------------------------------------------------------------------------------------- #

# Enable BBR congestion control.
net.ipv4.tcp_congestion_control = bbr

# Disallow IPv4 packet forwarding.
net.ipv4.ip_forward = 0

# Enable SYN cookies for SYN flooding protection.
net.ipv4.tcp_syncookies = 1

# Number of times SYNACKs for a passive TCP connection attempt will be retransmitted.
net.ipv4.tcp_synack_retries = 5

# Do not send redirects.
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.send_redirects = 0

# Do not accept packets with SRR option.
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_source_route = 0

# Enable reverse path source validation (BCP38).
# Refer to RFC1812, RFC2827, and BCP38 (http://www.bcp38.info).
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1

# Log packets with impossible addresses to kernel log.
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.log_martians = 1

# Do not accept ICMP redirect messages.
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0

# Disable sending and receiving of shared media redirects.
# This setting overwrites net.ipv4.conf.all.secure_redirects.
# Refer to RFC1620.
net.ipv4.conf.default.shared_media = 0
net.ipv4.conf.all.shared_media = 0

# Always use the best local address for announcing local IP via ARP.
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2

# Reply only if the target IP address is local address configured on the incoming interface.
net.ipv4.conf.default.arp_ignore = 1
net.ipv4.conf.all.arp_ignore = 1

# Drop Gratuitous ARP frames to prevent ARP poisoning.
# This can cause issues when ARP proxies are used in the network.
net.ipv4.conf.default.drop_gratuitous_arp = 1
net.ipv4.conf.all.drop_gratuitous_arp = 1

# Ignore all ICMP echo requests.
#net.ipv4.icmp_echo_ignore_all = 1

# Ignore all ICMP echo and timestamp requests sent to broadcast/multicast.
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore bad ICMP errors.
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Mitigate TIME-WAIT Assassination hazards in TCP.
# Refer to RFC1337.
net.ipv4.tcp_rfc1337 = 1

# Disable TCP window scaling.
# This makes the host less susceptible to TCP RST DoS attacks.
# Could drastically reduce throughput if latency is high.
#net.ipv4.tcp_window_scaling = 0

# Increase system IP port limits.
net.ipv4.ip_local_port_range = 1024 65535

# TCP timestamps could provide protection against wrapped sequence numbers,
# but the host's uptime can be calculated precisely from its timestamps.
# It is also possible to differentiate operating systems based on their use of timestamps:
#   - 0: disable TCP timestamps.
#   - 1: enable timestamps as defined in RFC1323 and use random offset for each connection rather than only using
#        the current time.
#   - 2: enable timestamps without random offsets.
net.ipv4.tcp_timestamps = 0

# Enabling SACK can increase the throughput.
# But SACK is commonly exploited and rarely used.
net.ipv4.tcp_sack = 0
net.ipv4.tcp_dsack = 0
net.ipv4.tcp_fack = 0

# Divide socket buffer evenly between TCP window size and application.
net.ipv4.tcp_adv_win_scale = 1

# SSR could impact TCP's performance on a fixed-speed network (e.g., wired),
# but it could be helpful on a variable-speed network (e.g., LTE).
net.ipv4.tcp_slow_start_after_idle = 0

# Enabling MTU probing helps mitigating PMTU blackhole issues.
# This may not be desirable on congested networks.
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_base_mss = 1024

# Increase memory thresholds to prevent packet dropping.
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608

# -------------------------------------------------------------------------------------------------------------------- #
# IPv6: Networking.
# -------------------------------------------------------------------------------------------------------------------- #

# Disable IPv6.
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Disallow IPv6 packet forwarding.
net.ipv6.conf.default.forwarding = 0
net.ipv6.conf.all.forwarding = 0

# Number of Router Solicitations to send until assuming no routers are present.
net.ipv6.conf.default.router_solicitations = 0
net.ipv6.conf.all.router_solicitations = 0

# Do not accept Router Preference from RA.
net.ipv6.conf.default.accept_ra_rtr_pref = 0
net.ipv6.conf.all.accept_ra_rtr_pref = 0

# Learn prefix information in router advertisement.
net.ipv6.conf.default.accept_ra_pinfo = 0
net.ipv6.conf.all.accept_ra_pinfo = 0

# Setting controls whether the system will accept Hop Limit settings from a router advertisement.
net.ipv6.conf.default.accept_ra_defrtr = 0
net.ipv6.conf.all.accept_ra_defrtr = 0

# Router advertisements can cause the system to assign a global unicast address to an interface.
net.ipv6.conf.default.autoconf = 0
net.ipv6.conf.all.autoconf = 0

# Number of neighbor solicitations to send out per address.
net.ipv6.conf.default.dad_transmits = 0
net.ipv6.conf.all.dad_transmits = 0

# Number of global unicast IPv6 addresses can be assigned to each interface.
net.ipv6.conf.default.max_addresses = 1
net.ipv6.conf.all.max_addresses = 1

# Enable IPv6 Privacy Extensions (RFC3041) and prefer the temporary address.
net.ipv6.conf.default.use_tempaddr = 2
net.ipv6.conf.all.use_tempaddr = 2

# Ignore IPv6 ICMP redirect messages.
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Do not accept packets with SRR option.
net.ipv6.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Ignore all ICMPv6 echo requests.
#net.ipv6.icmp.echo_ignore_all = 1
#net.ipv6.icmp.echo_ignore_anycast = 1
#net.ipv6.icmp.echo_ignore_multicast = 1
EOF
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
