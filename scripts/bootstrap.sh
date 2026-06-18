#!/bin/bash

SECONDS=0

# brew
sudo apt-get update 
sudo apt-get upgrade -y

sudo apt-get install build-essential procps curl file git -y
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# adds entries to default files for brew
echo >> /home/ubuntu/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/ubuntu/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

# install ansible
brew install ansible --yes

# already going to have the git repo locally so pull it
cd /home/ubuntu/git/ubuntu-bootstrap/
git pull

# run base playbook
ansible-playbook -i hosts playbooks/base.yaml --connection=local

# elapsed time
duration=$SECONDS
elapsed_seconds=$((end_time - start_time))
echo "bootstrap.sh completed - $((duration / 60)) minute(s) and $((duration % 60)) second(s) elapsed."