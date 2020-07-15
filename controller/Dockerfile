FROM alpine:latest

ENV ANSIBLE_HOST_KEY_CHECKING=False

RUN apk add --no-cache openssh ansible sshpass

CMD tail -f /dev/null