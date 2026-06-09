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

The other option I use is quickly use sed to replace the old hostname in the file with the current hostname set with `set-hostname`.  I'm going to eventually write a post install script to help with these steps.

```
sudo sed -i "s/template01/$(hostname)/g" /etc/hosts
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


# now copy/paste your server: entry from the forgejo dashboard into config file. Verify all settings.

- check IP and port
- check uuid
- check token
- check labels
- change these settings:
  * docker: automount
  * privileged: true


```bash
server:
  connections:
    forgejo:
      url: http://IP:3000/
      uuid: uuid
      token: token
      labels: [docker, ubuntu-latest]
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

# start/stop/restart service, enable service, and check logs
```bash
sudo systemctl daemon-reload 
sudo systemctl start forgejo-runner.service
sudo systemctl enable forgejo-runner.service
sudo journalctl -u forgejo-runner.service
```
check dashboard to see if node is working.

If you need to restart the service:
```
systemctl restart forgejo-runner
```