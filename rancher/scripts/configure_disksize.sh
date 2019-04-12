
#开始分区
fdisk -S 56 /dev/sda << EOF
n
p
2


wq
EOF

sudo partprobe

#格式化分区
sudo mkfs.ext4 /dev/sda2
#挂载分区
sudo mount /dev/sda2 /mnt
df -h