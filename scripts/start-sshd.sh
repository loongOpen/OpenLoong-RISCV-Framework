#!/system/bin/sh
exec >>/data/openssh/sshd-start.log 2>&1
echo '=== SSH starting ==='
id
exec /system/bin/sshd -D -e -f /data/openssh/sshd_config
