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
		tar \
		git \
		deltarpm \
		make \
		gcc \
		zlib-devel \
		bzip2 \
		bzip2-devel \
		readline-devel \
		sqlite \
		sqlite-devel \
		openssl-devel \
		tk-devel \
		libffi-devel
		
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install and setup Supervisord
echo "Installing amazon-linux-extras..."
amazon-linux-extras install -y epel
yum install -y supervisor

echo "Cleaning up yum cache..."
yum clean all
rm -rf /var/cache/yum


###### Here is where we setup PyEnv, so we can have nice things ######
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

# Check to see if .pyenv folder exists
# 	If .pyenv directory does not exist, we will create and clone PyEnv from GitHub repository
if [ ! -d "$PYENV_ROOT" ]; then
  echo "PYENV_ROOT [$PYENV_ROOT] does NOT exist."
  
  git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
  git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

fi

# Setup PyEnv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

eval "$(pyenv virtualenv-init -)"

# Install python versions via PyEnv
PYENV_PYTHON_VERSION="3.8.1"

if [ ! -d "$PYENV_ROOT/versions/$PYENV_PYTHON_VERSION" ]; then
	echo "pyenv: Python version $PYENV_PYTHON_VERSION is currently not installed."
	echo "pyenv: Installing python version $PYENV_PYTHON_VERSION"
	pyenv install $PYENV_PYTHON_VERSION

	echo "pyenv: Setting global python version $PYENV_PYTHON_VERSION"
	pyenv global $PYENV_PYTHON_VERSION

	## Here is where you install all your packages
	# Upgrading pip
	echo "Upgrading pip"
	pip install --upgrade pip

	# Install AWS CLI  manually
	echo "Installing AWSCLI via pip"
	curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
	unzip awscli-bundle.zip
	./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

	echo "Installing EBCLI via pip"
	pip install awsebcli

	echo "Installing EBCLI via pip"
	pip install speedtest-cli

	echo "Installing boto3"
	pip install boto3
	
fi

###### END PyEnv Setup ######


# Kubectl install
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# eksctl install
echo "Installing eksctl"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/eksctl


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