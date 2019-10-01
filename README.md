# ami2ssh Repository

This is a Docker Image of Amazon Linux 2 AMI with the necessary troubleshooting tools. It can be use in troubleshooting ECS Fargate networking issues or simply as just an image to troubleshoot. It is small in and easy to use.

build

```
$ docker build -t amazonlinux-sshd:latest .
```

run

```
$ docker run --rm -p 10022:22 -e ROOT_PW=password_to_login  -t amazonlinux-sshd:latest
```

## ENV

- `ROOT_PW`: password for root login (default: `rooooot`)

Release Notes

v1.0 - First commit