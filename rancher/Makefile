run:
    vagrant up
install:
    mv /root/code/vagrant/rancher/rancher.service /usr/lib/systemd/system
    systemctl enable rancher.server
    systemctl start rancher.server
