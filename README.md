## ubuntu-bootstrap

### This repo will bootstrap ubuntu LTS containers with ansible

### prerequisites
run updates and install brew
```
sudo apt-get update 
sudo apt-get upgrade -y

sudo apt-get install build-essential -y
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# adds entries to default files for brew
echo >> /home/ubuntu/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/ubuntu/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
```

install ansible
```
# install ansible
brew install ansible

# check version
ansible --version
```

create git directory and clone repo
```
mkdir ~/git/
cd ~/git/
git clone https://github.com/thesheff17/ubuntu-bootstrap
```

# run playbook
```
cd ubuntu-bootstrap
ansible-playbook -i hosts2 playbooks/base.yaml --connection=local
```