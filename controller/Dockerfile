FROM alpine:latest

WORKDIR /root/

ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV ANSIBLE_PYTHON_INTERPRETER=auto_silent

RUN apk add --no-cache openssh ansible sshpass

CMD tail -f /dev/null