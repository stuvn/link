dd if=/dev/zero of=/var/swapfile bs=1M count=1024
mkswap -f /var/swapfile && chmod 600 /var/swapfile
swapon /var/swapfile
/sbin/swapon -s
echo "/var/swapfile swap swap defaults 0 0" >>/etc/fstab