# todo

This is a dumping ground of random things I would like to eventually do. 

- [x] - write a playbook for ssh service or add to base.yaml
- [x] - get forgejo ready to display on twitch and make sure the forgejo runner logs can be shown.  Demo tests and see if I can run the vscode playbook.
- [ ] - create an agents.md file for this repo.
- [ ] - test using python uv setup to manage python pip packages.  Write some documenataion for this.

- [x] - does the auto install script work with xubuntu-* as well as ubuntu-*?  It does not work.  You need to make sure to use the ISO/install script per ubuntu distro flavor.
- [x] - get rid of any ansible warnings - added some code.  Just needs some testing.
- [x] - it looks like the forgejo playbook is also doing variable injectection?  Does this warn/error when running and is there an actual patch/recommended way of doing this now?

- [x] - automate vscode install
- [ ] - automate monitor tool with docker support https://beszel.dev/
- [ ] - playbook for mysql
- [ ] - playbook for postgres
- [ ] - playbook for valkey
- [ ] - I should have a simple backup plan for important data (mysql data, postgres data, valkey data, etc)
- [ ] - start a playbook for python 3rd party libraries (django, https://python-rq.org/, flask, sqlachemy, etc)

# stuff that is optional I may never get to or needs further documenation/info to be flushed out:
- [ ] - start learning other programming languages (odin: https://www.youtube.com/watch?v=xDNSS9oZYPo)
- [ ] - checkout custom django admin themes: https://grappelliproject.com/
- [ ] - check out this programming language [vala](https://vala.dev/)
- [ ] - automate install of AI tools ansible playbooks
- [ ] - is it possible to clone a runner and have it work? or does it need a new token/register?