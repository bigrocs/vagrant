run:
	vagrant up
install:
	mv /root/code/vagrant/rancher/vagrant /etc/rc.d/init.d 
	chmod +x /etc/rc.d/init.d/vagrant
	chkconfig --add vagrant
	systemctl enable vagrant