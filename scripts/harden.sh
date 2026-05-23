#!/bin/bash
# CIS hardening baseline for RHEL 9 Packer build
set -euo pipefail

echo "=== Applying security hardening ==="

# Update all packages
dnf update -y

# Install security tools
dnf install -y aide rkhunter auditd firewalld fail2ban

# Disable unused filesystems
cat >> /etc/modprobe.d/cis-hardening.conf << 'EOF'
install cramfs /bin/true
install freevxfs /bin/true
install jffs2 /bin/true
install hfs /bin/true
install hfsplus /bin/true
EOF

# SSH hardening
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 4/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

# Enable services
systemctl enable auditd firewalld

# Initialize AIDE
aide --init && mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Clean up
dnf clean all
rm -rf /tmp/* /var/tmp/*
echo "Hardening complete."
