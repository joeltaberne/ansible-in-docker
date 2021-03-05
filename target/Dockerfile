FROM alpine:latest

RUN apk add --no-cache openssh python3 && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication no/g' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config && \
    echo "root:123" | chpasswd && \
    ssh-keygen -A

CMD /usr/sbin/sshd && tail -f /dev/null