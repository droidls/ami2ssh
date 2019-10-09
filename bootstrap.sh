#!/bin/bash

install -d /root/.ssh -m 0700

yum -y update

yum install -y \
		openssh-server \
		openssh-clients \
		mtr \
		iftop \
		ec2-utils \
		sudo \
		passwd \
		which \
		less \
		httpd \
		bind-utils\
		net-tools \
		telnet \
		iputils \
		traceroute \
		nmap \
		procps \
		jq \
		tree \
		top \
		ping \
		nmap-ncat \
		unzip \
		python3;

yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install and setup Supervisord
amazon-linux-extras install -y epel
yum install -y supervisor

yum clean all
rm -rf /var/cache/yum


# AWS CLI install manually
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws


# Configure SSH 
sed -i s/PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && sed -i s/PasswordAuthentication.*/PasswordAuthentication\ yes/ /etc/ssh/sshd_config \
  && sed -i s/#PermitUserEnvironment.*/PermitUserEnvironment\ yes/ /etc/ssh/sshd_config

env > /tmp/env.txt
env | grep AWS_ >> /root/.ssh/environment

root_pw=${ROOT_PW:-mypassword}

# generate host keys if not present
ssh-keygen -A

echo "root:$root_pw" | chpasswd