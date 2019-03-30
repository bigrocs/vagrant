sudo umount /dev/sda1
sudo fdisk /dev/sda<< EOF
n
p
1


wq
EOF
sudo resize2fs /dev/sda1
sudo mount /dev/sda1