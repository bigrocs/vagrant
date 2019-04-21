docker_version=${1:-docker-ce}
os_password=${2:-os_password}
# 修改密码
echo root:$os_password | chpasswd
echo vagrant:$os_password | chpasswd
# 设置时区为上海时区
sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#sudo  安装 docker 环境
sudo yum install -y wget yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum makecache fast
sudo yum -y install --setopt=obsoletes=0 $docker_version
sudo service docker start
sudo systemctl enable docker

# 设置阿里云镜像日志大小
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://za6g16o8.mirror.aliyuncs.com"],
  "log-driver":"json-file",
  "log-opts":{ "max-size" :"50m","max-file":"3"}
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
# 允许y用户名登录
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
# 重启 sshd 关闭防火墙
systemctl restart sshd.service && systemctl stop firewalld.service && systemctl disable firewalld.service
# 检测 docker 安装情况
sudo docker -v

# 安装 open-iscsi
yum install -y iscsi-initiator-utils

# 安装 jq
sudo yum -y install epel-release
sudo yum -y install jq

# Kernel性能调优
sudo tee >> /etc/sysctl.conf<<-'EOF'
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.neigh.default.gc_thresh1=4096
net.ipv4.neigh.default.gc_thresh2=6144
net.ipv4.neigh.default.gc_thresh3=8192
EOF
sudo sysctl -p