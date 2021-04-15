sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 178.76.146.63
sudo ufw allow from 68.184.25.52
sudo ufw allow 11000:65535/udp
sudo ufw allow 11000:65535/tcp
sudo ufw enable