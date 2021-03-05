#!/bin/sh

if [[ $(docker ps -aqf "name=ansible-in-docker" | wc -l) != 0 ]];then
    echo "Removing old ansible-in-docker containers..."
    docker rm -f $(docker ps -aqf "name=ansible-in-docker") >> /dev/null
fi
echo -n "How many targets do you want to use?: "
read n
echo "Setting up ansible environment with $n targets..."
docker-compose -f docker-compose.yml up -d --scale target=$n
echo "[hosts]" > /tmp/ansible-in-docker-hosts
echo $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aqf "name=target")) >> /tmp/ansible-in-docker-hosts
sed -i 's/\s\+/\n/g' /tmp/ansible-in-docker-hosts
echo "
[all:vars]
ansible_connection=ssh
ansible_user=root
ansible_ssh_pass=123" >> /tmp/ansible-in-docker-hosts
docker cp /tmp/ansible-in-docker-hosts ansible-in-docker_controller_1:/root/hosts