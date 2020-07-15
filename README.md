# alpine-docker-ansible
Ansible testing environment based in alpine docker images.

The main purpose of this project is being able to test Ansible modules and playbooks with as many targets as we want, and making it light, fast and simple.

First step is creating an image with only the required packages for Ansible to work properly as a controller. The image will be created from this Dockerfile (controller/Dockerfile):

```
FROM alpine:latest

ENV ANSIBLE_HOST_KEY_CHECKING=False

RUN apk add --no-cache openssh sshpass ansible

CMD tail -f /dev/null
```

Nothing else is needed for Ansible to work as a controller apart from Ansible itself, openssh and sshpass packages, so next step is setting up the target image from the following Dockerfile (target/Dockerfile):

```
FROM alpine:latest

RUN apk add --no-cache openssh python3
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

RUN echo "root:123" | chpasswd
RUN ssh-keygen -A

CMD /usr/sbin/sshd && tail -f /dev/null
```

This image installs openssh service and changes its configuration to be able to accept remote root logins, python3 which will interpret Ansible modules, and finally sets a default root password "123" and generates ssh keys.
It also has a CMD entry in detached mode to start sshd service once the container is run.

You can either build these two Dockerfiles or pull them from my dockerhub with:

```
docker pull joeltf99/alpine-ansible-controller
docker pull joeltf99/alpine-ansible-target
```

Once the images are available, create a new docker network to isolate the containers we will create and make them able to talk to each other.

```
docker network create ansible-test
```

Now the bridge network is created, containers can be launched.

First, execute the controller in both detached and interactive mode inside the ansible-test network we just created with name "controller":

```
docker run -dti --network ansible-test --name controller joeltf99/alpine-ansible-controller sh
```

Next, we will run two targets in detached mode inside the ansible-test network with names "target1" and "target2":

```
docker run -d --network ansible-test --name target1 joeltf99/alpine-ansible-target
docker run -d --network ansible-test --name target2 joeltf99/alpine-ansible-target
```

With docker ps we can check every container is running:

```
PS C:\Users\Joel> docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED
STATUS                  PORTS               NAMES
db7a5573ef40        joeltf99/alpine-ansible-target       "/bin/sh -c '/usr/sb…"   2 seconds ago       Up Less than a second                       target2
be923afdc91d        joeltf99/alpine-ansible-target       "/bin/sh -c '/usr/sb…"   7 seconds ago       Up 5 seconds                                target1
27fd9fc5773d        joeltf99/alpine-ansible-controller   "sh"                     19 seconds ago      Up 17 seconds                               controller
```

We can now attach to the controller to test more in depth whether Ansible works properly:

```
PS C:\Users\Joel> docker attach controller
/ #
```

Now we can create a simple inventory to let Ansible know which are the hosts and how we will connect to them:

```
cat > /inventory.txt
target1 ansible_host=172.18.0.3 ansible_connection=ssh ansible_ssh_user=root ansible_ssh_pass=123
target2 ansible_host=172.18.0.4 ansible_connection=ssh ansible_ssh_user=root ansible_ssh_pass=123
```

(Remember we set root password to be "123" in targets Dockerfile.)

(You can check which are the IP addresses from each container with the following command):

```
PS C:\Users\Joel> docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' controller
172.18.0.2
PS C:\Users\Joel> docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' target1
172.18.0.3
PS C:\Users\Joel> docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' target2
172.18.0.4
```

With the inventory created, we can now test Ansible with a simple ping module like this:

```
/ # ansible -m ping -i inventory.txt all
target2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
target1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

The ping worked correctly so the testing environment is properly set up.
