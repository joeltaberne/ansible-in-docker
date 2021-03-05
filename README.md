# Ansible in docker !
Ansible testing environment based in alpine docker images.

The main purpose of this project is being able to test Ansible modules and playbooks with as many targets as we want, and making it light, fast and simple.

First step is creating an image with only the required packages for Ansible to work properly as a controller. The image will be created from this Dockerfile (controller/Dockerfile):

```
FROM alpine:latest

ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV ANSIBLE_PYTHON_INTERPRETER=auto_silent

RUN apk add --no-cache openssh sshpass ansible

CMD tail -f /dev/null
```

Nothing else is needed for Ansible to work as a controller apart from Ansible itself, openssh and sshpass packages, so next step is setting up the target image from the following Dockerfile (target/Dockerfile):

```
FROM alpine:latest

RUN apk add --no-cache openssh python3 && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication no/g' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config && \
    echo "root:123" | chpasswd && \
    ssh-keygen -A

CMD /usr/sbin/sshd && tail -f /dev/null
```

This image installs openssh service and changes its configuration to be able to accept remote root logins, python3 which will interpret Ansible modules, and finally sets a default root password "123" and generates ssh keys.
It also has a CMD entry in detached mode to start sshd service once the container is run.

To setup the ansible environment you have to execute the setup script. You will be prompted for the number of targets desired, the controller and target images will be pulled, and the containers will be created

```
joeltaberne@pop-os:~/gitProjects/ansible-in-docker $ bash setup.sh 
How many targets do you want to use?: 3
Setting up ansible environment with 3 targets...
Creating ansible-in-docker_target_1     ... done
Creating ansible-in-docker_target_2     ... done
Creating ansible-in-docker_target_3     ... done
Creating ansible-in-docker_controller_1 ... done
```

Once the process finishes you are able to access the controller container with:

```
joeltaberne@pop-os:~/gitProjects/ansible-in-docker $ docker exec -ti ansible-in-docker_controller_1 sh
~ # 
```

Script automatically creates an inventory with the targets hosts:

```
~ # cat hosts
[hosts]
172.18.0.5
172.18.0.3
172.18.0.2

[all:vars]
ansible_connection=ssh
ansible_user=root
ansible_ssh_pass=123
~ # 
```

You can test the environment working properly by sending a ping through Ansible to all hosts:

```
~ # ansible -m ping -i hosts all
172.18.0.3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
172.18.0.2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
172.18.0.5 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

The ping worked correctly so the testing environment is properly set up and you are free to test your own playbooks and commands.