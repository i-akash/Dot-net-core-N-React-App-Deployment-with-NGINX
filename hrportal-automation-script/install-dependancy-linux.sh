#                               install

sudo apt-get install openssh-server
sudo apt-get install ufw 
sudo apt-get install nginx

# dot net core run time 
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update; 
sudo apt-get install -y apt-transport-https 
sudo apt-get update 
sudo apt-get install -y aspnetcore-runtime-3.1

# mssql 
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
sudo apt-get update
sudo apt-get install -y mssql-server
sudo /opt/mssql/bin/mssql-conf setup

# npm
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install nodejs


# status
sudo systemctl status ssh