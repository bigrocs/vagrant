
#开始分区
fdisk -S 56 /dev/sda << EOF
n
p
2


wq
EOF

sudo partprobe
# 自动格式化并挂载数据盘
type=ext4
mount_dir=/www
sudo mkdir $mount_dir
sudo mkfs.$type /dev/sda2 
sudo echo "/dev/sda2 $mount_dir $type defaults 0 0" >> /etc/fstab
sudo mount -a