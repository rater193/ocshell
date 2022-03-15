sudo apt-get update
sudo apt-get install nodejs npm zip unzip rar unrar -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 188.210.7.189
sudo ufw allow from 68.184.25.52
sudo ufw allow 80:80/tcp
sudo ufw allow 80:80/udp
sudo ufw allow 443:443/tcp
sudo ufw allow 443:443/udp
sudo ufw allow 11000:65535/udp
sudo ufw allow 11000:65535/tcp
sudo ufw enable
