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

# setting up a forgejo worker

clone ubuntu 26.04 template

set hostname
```bash
sudo hostnamectl set-hostname forg-worker-01
```

edit /etc/hosts and set `127.0.1.1` to `forg-worker-01` example:
```bash
127.0.0.1 localhost
127.0.1.1 forg-worker-01

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

# configure the node with the `base.yaml` above and reboot.


# setup forgejo and auth for runners

on the for forgejo dashboard select profile icon top right, select settings, actions, runners, create new runner. Document this information somewhere safe and not in git.  

# install forgejo binary.
```bash
export ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
export RUNNER_VERSION=$(curl -X 'GET' https://data.forgejo.org/api/v1/repos/forgejo/runner/releases/latest | jq .name -r | cut -c 2-)
export FORGEJO_URL="https://code.forgejo.org/forgejo/runner/releases/download/v${RUNNER_VERSION}/forgejo-runner-${RUNNER_VERSION}-linux-${ARCH}"
wget -O forgejo-runner ${FORGEJO_URL} || curl -o forgejo-runner ${FORGEJO_URL}
chmod +x forgejo-runner
wget -O forgejo-runner.asc ${FORGEJO_URL}.asc || curl -o forgejo-runner.asc ${FORGEJO_URL}.asc
gpg --keyserver hkps://keys.openpgp.org --recv EB114F5E6C0DC2BCDD183550A4B61A2DC5923710
gpg --verify forgejo-runner.asc forgejo-runner && echo "✓ Verified" || echo "✗ Failed"
# Good signature from "Forgejo <contact@forgejo.org>"
#         aka "Forgejo Releases <release@forgejo.org>"
# ✓ Verified

# install binary
sudo cp forgejo-runner /usr/local/bin/forgejo-runner

# generate new config file
forgejo-runner generate-config > /home/ubuntu/runner-config.yml
```


```bash
# now copy/paste your server: entry from the forgejo dashboard into config file.
server:
  connections:
    forgejo:
      url: http://IP:3000/
      uuid: uuid
      token: token
      labels: [docker]
```

start service in forground for testing.  Replace IP and uuid-number below.
```bash
forgejo-runner daemon -c /home/ubuntu/runner-config.yml
```
check forgejo dashboard.  The runner should be green and idle.

create your first runner yaml file under: `.forgejo/workflows/demo.yaml` and add the following:
```yml
name: Run My Task
on: 
  push:         # Triggers the task every time you push code
    branches: [ main ]

jobs:
  my-task:
    runs-on: docker  # MUST match your runner's label
    steps:
      - name: Check out repository code
        uses: actions/checkout@v4
        
      - name: Run a shell command
        run: echo "Hello from the Forgejo runner!"
```

setup runner to run as a service
create: `/etc/systemd/system/forgejo-runner.service`

```bash
[Unit]
Description=Forgejo Runner
Documentation=https://forgejo.org/docs/latest/admin/actions/
After=docker.service

[Service]
ExecStart=/usr/local/bin/forgejo-runner daemon -c /home/ubuntu/runner-config.yml
ExecReload=/bin/kill -s HUP $MAINPID

# This user and working directory must already exist
User=ubuntu
WorkingDirectory=/home/ubuntu
Restart=on-failure
# allow configured shutdown_timeout to be effective, rather than overridden by systemd
TimeoutStopSec=infinity
RestartSec=10

[Install]
WantedBy=multi-user.target
```

# start service and check
```bash
sudo systemctl daemon-reload 
sudo systemctl start forgejo-runner.service
sudo systemctl enable forgejo-runner.service
sudo journalctl -u forgejo-runner.service
```
check dashboard to see if node is working.
