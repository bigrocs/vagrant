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
chmod -x /opt/backupstore
```
- vim /etc/exports
```
/opt/backupstore/ *(rw,sync,fsid=0)
```
```
systemctl start nfs.service
```
- nfs://192.168.1.10:/opt/backupstore