# ubuntu-bootstrap

## This repo will bootstrap ubuntu LTS containers with ansible

### prerequisites

make sure sudo does not require a password:
```bash
sudo visudo

# add this to 2nd to last line:
ubuntu ALL=(ALL) NOPASSWD: ALL
```

run updates and install brew.  brew does not like to be ran as root.  Make sure you run this as a non privileged user and use `sudo` 
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
brew install ansible --yes

# check version
ansible --version
```

create git directory and clone repo
```bash
mkdir ~/git/
cd ~/git/
git clone https://github.com/thesheff17/ubuntu-bootstrap
```
# optional: change scroll touchpad direction
```bash
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false
```

# run base playbook

default base playbook contains basic packages + docker
```bash
cd ubuntu-bootstrap
time ansible-playbook -i hosts playbooks/base.yaml --connection=local
sudo reboot

# sudo systemctl reboot -i
```

There is a helper script in `scripts/boostrap.sh`

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

- [forgejo-worker](./tutorials/forgejo-worker.md)
- [other-playbooks](./tutorials/other-playbooks.md)
- [todo](./tutorials/todo.md)

# Why isn't there a playbook for a forgejo-worker?

While I think it would be possible to write this into a playbook it is a very limit subset of commands and requires a reboot after setting hostname.  It also contains sesitive tokens you will get from the forgejo server.  This is more proned to error if you don't know what you are doing.  Since my forgejo workers are virtual machines in proxmox I can scale these easily with CPU/RAM and just have a handful of runners.  If you need to scale to a crazy amount of runners I'm sure it can be scripted out but is beyond the scope of this repo.

# is there a release/install structure?

No not at this time.  I consider this all a very experimental code base and I assume you know what you are doing if you are using any of this.  I am also constantly patching/updating CI/CD pipelines (forgejo actions).

Make your own versions up if you want to manage the code like this.
```
git clone https://github.com/thesheff17/ubuntu-bootstrap ubuntu-bootstrap-1.0 
```
Time passes:
```
git clone https://github.com/thesheff17/ubuntu-bootstrap ubuntu-bootstrap-1.1
```
compare versions:
```
diff -r ubuntu-bootstrap-1.0 ubuntu-bootstrap-1.1
```


# how do I ask questions or make changes?

- [discussions](https://github.com/thesheff17/ubuntu-bootstrap/discussions) ask questions here.
- [issues](https://github.com/thesheff17/ubuntu-bootstrap/issues) open an issue here.

- [pull requests](https://github.com/thesheff17/ubuntu-bootstrap/pulls) open a pull request here.

# do you use AI tools? 

yes I'm using a bunch random local tools.  I won't pay for any of this.

- [llama.cpp](https://github.com/ggml-org/llama.cpp)
- [lm studio](https://lmstudio.ai/)
- [langchain](https://github.com/langchain-ai/langchain)
- [opencode](https://opencode.ai/)

# preparing a bare metal laptop for testing:

- install latest ubuntu desktop LTS
- run updates and reboot
- disable power management stuff
- install ssh, add your public key(s), and start/enable services
- disable sudo password
- download the repo so you have the suppot scripts so you don't even have to copy/paste.  Should be in /home/ubuntu/git/ubuntu-bootstrap/ directory.
- take timeshift image so you can restore at this point.  
    This should be super easy to reastore to this point and then continue testing.
    `sudo timeshift --restore`
