FROM alpine:latest

RUN apk add --no-cache openssh python3

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

RUN sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication no/g' /etc/ssh/sshd_config

RUN sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

RUN echo "root:123" | chpasswd

RUN ssh-keygen -A

CMD /usr/sbin/sshd && tail -f /dev/null