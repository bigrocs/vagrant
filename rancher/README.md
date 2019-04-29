# vagrant-rancher

#### rancher
- 快速启动集群
- 提前安装 vagrant
- vagrant plugin install vagrant-disksize
- vagrant up
#### 环境说明
- centos/7 作为基础系统

#### NFS backupstore
- nfs://longhorn-test-nfs-svc.default:/opt/backupstore
```
mkdir /opt/backupstore
chmod -R 777 /opt/backupstore
```
- vim /etc/exports
```
/opt/backupstore * (rw,sync,all_squash)
```
```
systemctl start nfs.service
```
- nfs://192.168.1.10:/opt/backupstore
- 需要单独关闭防火墙或者开放对应端口
- systemctl restart sshd.service && systemctl stop firewalld.service && systemctl disable firewalld.service


### 修改计算机名称 ip
- sudo hostnamectl set-hostname master-01
- cd /etc/sysconfig/network-scripts
- vi ifcfg-enp0s17

### 重新启动：
- VBoxManage controlvm master-01 reset
### 关机：
- VBoxManage controlvm master-01 poweroff
### 无界面启动
- vboxmanage startvm master-01 --type headless