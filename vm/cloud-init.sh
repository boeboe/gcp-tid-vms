#!/bin/bash
echo "===== cloud-init.sh STARTED ====="

# Install packages
echo "===== install packages ====="
sudo apt-get -y update
sudo apt-get -y install ca-certificates curl httpie wget gnupg lsb-release jq tree dnsutils iputils-ping iputils-arping iputils-tracepath openssl net-tools

# Add docker engine repo
echo "===== add docker engine repo ====="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install docker-ce
echo "===== install docker-ce ====="
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ${USER}
sudo apt-get -y autoremove

# Get metadata information
echo "===== get metadata information ====="
INSTANCE_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/name -H "Metadata-Flavor: Google")
PROJECT_ZONE=$(curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google")
ZONE=$(echo ${PROJECT_ZONE} | sed 's/\// /3' | awk '{print $2}')
REGION=$(echo ${ZONE} | sed 's/-/ /2' | awk '{print $1}')

# Start docker container
echo "===== start docker container ====="
docker run -d \
  --net host \
  --name=${INSTANCE_NAME} \
  --env=HTTP_PORT=8080 \
  --env=MSG="VM Hosted JSON Server ${INSTANCE_NAME}" \
  --env=REGION=${REGION} \
  --env=ZONE=${ZONE} \
  boeboe/json-server

echo "===== cloud-init.sh DONE ====="
