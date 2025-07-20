set -e

cd /tmp
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -a -G docker $USER

sudo systemctl enable docker
sudo systemctl start docker
