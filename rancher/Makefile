install:
    #自动启动文件请把 run 的命令写入 rc.local
    chmod +x /etc/rc.d/rc.local
	vagrant up
run:
	vboxmanage startvm server --type headless
    vboxmanage startvm master-01 --type headless
    vboxmanage startvm master-02 --type headless
    vboxmanage startvm master-03 --type headless
    vboxmanage startvm master-04 --type headless
    vboxmanage startvm master-05 --type headless
    vboxmanage startvm master-06 --type headless
    vboxmanage startvm node-01 --type headless
    vboxmanage startvm node-02 --type headless
    vboxmanage startvm node-03 --type headless
    vboxmanage startvm node-04 --type headless
    vboxmanage startvm node-05 --type headless
    vboxmanage startvm node-06 --type headless
    vboxmanage startvm node-07 --type headless
    vboxmanage startvm node-08 --type headless
    vboxmanage startvm node-09 --type headless

    vboxmanage startvm win2003 --type headless
# 重新启动：
# VBoxManage controlvm dcsvr08 reset
# 关机：
# VBoxManage controlvm dcsvr08 poweroff