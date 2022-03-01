curl -fsSL https://get.docker.com | sh

sudo groupadd docker
sudo usermod -aG docker $USER

sudo echo "{ \"log-driver\": \"local\", \"log-opts\": { \"max-size\": \"10m\", \"max-file\": \"3\" } }" > /etc/docker/daemon.json

echo "Will reboot in 5"
sleep 5
sudo reboot 