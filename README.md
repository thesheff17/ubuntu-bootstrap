# ubuntu-bootstrap

## This repo will bootstrap ubuntu LTS containers with ansible

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

sudo apt-get install build-essential procps curl file git -y
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
sudo reboot
```

deploy [forgejo](https://forgejo.org/)

```bash
time ansible-playbook -i hosts playbooks/deploy-forgejo.yaml --connection=local
```
Now visit http://IP:3000 and follow the forgejo installation.

## make sure you watch port numbers when running git remote add

One thing I ran into is make sure when you go to add your additional `git remote add origin2 url` that you use: `ssh://git@IP:222/username/repo-name.git` with the port number.  The forgejo website doesn't have port number and if you leave out the port number it will try to talk to the docker host and not the forgejo container running inside docker.  Look at `/opt/forgejo/docker-compose.yml` to control this more.  Backups of this data are outside this scope but forgejo provides great documentation on upgrading.  Check out the docs [here.](https://forgejo.org/docs/latest/admin/upgrade/)


# why forgejo vs github.com

github.com has been a disaster since microsoft took over.  I will mirror this repo to github.com but it may be significantly behind my local forgejo setup.  I no longer consider github.com a viable solution for developers/companies anymore.  You should really consider self hosting at this point. If you want a decent review on why, watch this youtube video [here.](https://www.youtube.com/watch?v=d53Zk28esmU) Loosing pull requests and code are crazy to me.  Also don't get me started on github actions and pricing.  At this point I would rather just run my own git runners through forgejo.  Microsoft/github you can do better.

# which order to run playbooks

Always run `base.yaml` first and `reboot` to setup basic packages and docker.  Then all other playbooks should be self contained.  You should not have playbooks depend on other playbooks.  I would rather have some duplicated playbook code vs a crazy dependency tree for playbook order.  At any given time you should be able to run `base.yaml` and 1 other playbook to configure the service/server.  Ask if you have questions. 

# automatically display IP address on console without login
create file: `/etc/issue` and add the following 3 lines.  Change`ens18` to your network adapter.  This should display the IPV4 address at login screen without logging in.  This helped when I was using proxmox and testing a bunch of different Virtual machines I didn't want to login to get the IP.
```bash
Ubuntu 26.04 LTS
IP: \4{ens18}
\l
```

# tutorials

I will link to the current tutorials I am working on.  Please make PR if you see issues.  

[forgejo-worker](./tutorials/forgejo-worker.md)

# do you use AI tools? 

yes I'm using a bunch random local tools.  I won't pay for any of this.

- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [lm studio](https://lmstudio.ai/)
- [langchain](https://github.com/langchain-ai/langchain)
- [opecode](https://opencode.ai/)