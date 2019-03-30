address=${1:-192.168.1.10}
auth_path=${2:-btlogin}
default_name=${3:-btadmin}
default_password=${4:-btadmin}

port='8888'
# 安装命令
sudo yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh<< EOF




y
EOF
# 重置参数设定
admin_auth='/www/server/panel/data/admin_path.pl'
echo "/$auth_path" > $admin_auth
auth_path=`cat $admin_auth`
# 修改源码 tools.py 文件
sudo sed -i 's/set_panel_username()/set_panel_username(sys.argv[2])/g' '/www/server/panel/tools.py'
cd /www/server/panel
sudo python tools.py username $default_name
sudo python tools.py panel $default_password
sudo /etc/init.d/bt restart
echo  "重置路径账号密码"
echo  "Bt-Panel: http://$address:$port$auth_path"
echo -e "username: $default_name"
echo -e "password: $default_password"``