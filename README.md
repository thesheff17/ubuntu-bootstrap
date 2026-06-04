## ubuntu-bootstrap

### This repo will bootstrap ubuntu LTS containers with ansible

### prerequisites

make sure sudo does not require a password:
```bash
sudo visudo

# add this to 2nd to last line:
ubuntu ALL=(ALL) NOPASSWD: ALL
```

run updates and install brew
```bash
sudo apt-get update 
sudo apt-get upgrade -y

sudo apt-get install build-essential -y
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# adds entries to default files for brew
echo >> /home/ubuntu/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/ubuntu/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
```

install ansible
```bash
# install ansible
brew install ansible

# check version
ansible --version
```

create git directory and clone repo
```bash
mkdir ~/git/
cd ~/git/
git clone https://github.com/thesheff17/ubuntu-bootstrap
```

# run base playbook

default base playbook contains basic packages + docker
```bash
cd ubuntu-bootstrap
time ansible-playbook -i hosts playbooks/base.yaml --connection=local
```

deploy [forgejo](https://forgejo.org/) using docker

```bash
time ansible-playbook -i hosts playbooks/deploy-forgejo.yaml --connection=local
```
Now visit http://IP:3000 and follow the forgejo installation.

One thing I ran into is make sure when you go to add your additional `git remote add origin2 url` that you use: `ssh://git@IP:222/username/repo-name.git` with the port number.  The forgejo website doesn't have this and if you leave out the port number it will try to talk to the docker host and not the forgejo container.