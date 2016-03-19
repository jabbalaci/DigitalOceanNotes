Digital Ocean (notes and dotfiles)
==================================

Here I sum up how to configure a VPS (virtual private server) running
Ubuntu Linux. I tried it with Digital Ocean, but it must be the same
with others too, like Linode, etc.

As a basis, I used the following blog posts:
* [Initial Server Setup with Ubuntu 12.04](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-12-04)
* [How To Set Up Your Linode For Maximum Awesomeness](http://feross.org/how-to-setup-your-linode/)

For a detailed guide, read those blog posts. Here I just sum up the steps shortly.

start
-----
You bought your VPS. You get an email that contains info how to log in.
Log in as root:

    $ ssh root@1.2.3.4

You'll have to change your password.

new user
--------
Create a new user:

    # adduser demo

Here my user is called `demo`. The `#` indicates an admin prompt, while the `$`
is the prompt of a normal user.

admin rights to the new user
----------------------------
First let's set your favorite text editor:

    # update-alternatives --config editor

Then launch:

    # visudo

In the file find this line:

    root ALL=(ALL:ALL) ALL

And add the following line right below this line:

    demo ALL=(ALL:ALL) ALL

(Again, instead of `demo` use your user's account name).

Add your user to the sudo group:

    # usermod -a -G sudo demo

Where `demo` is the user's name.

time zone
---------
Set your time zone:

    # dpkg-reconfigure tzdata

packages
--------
Update your packages:

    # aptitude update
    # aptitude upgrade

configure SSH
-------------

    # vi /etc/ssh/sshd_config

In the file do these changes:

    Port 22    ->    Port 1234

The default port of SSH is 22. Here I changed it to port 1234.

    PermitRootLogin yes    ->    PermitRootLogin no

The root cannot log in via SSH. You will be able to log in as a normal user only.

Then, add these lines to the end:

    UseDNS no
    AllowUsers demo

Only the user called `demo` has the right to log in via SSH.

Save and reload the settings:

    # reload ssh

test SSH settings
-----------------
*!!! Don't log out as root yet !!!* Try to log in as a normal user:

    $ ssh demo@1.2.3.4

Test if you can sudo:

    $ sudo su

If it's OK, then in the other terminal you can log out as root.

security #1
-----------
Install Fail2Ban:

    # aptitude install fail2ban

Configure it:

    # cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    # vi /etc/fail2ban/jail.local

In the file, find this section and modify some lines:

    [ssh-ddos]
    enabled = false    ->    enabled = true
    port = ssh         ->    port = 1234

Here my SSH is on port 1234. Set these changes in another section too:

    [ssh]
    port = ssh         ->    port = 1234

Save and restart the service:

    # service fail2ban restart

security #2
-----------
Set your firewall.

    # apt-get install ufw

I use this script to set up my firewall:

    #!/usr/bin/env bash

    sudo ufw reset
    sudo ufw disable

    # my SSH is here
    sudo ufw allow 1234/tcp
    # say you have a webapp on port 9000 that you want to open
    sudo ufw allow 9000/tcp

    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    sudo ufw enable

    sudo ufw status verbose

useful programs
---------------
Compiler:

    # aptitude install build-essential

Python:

    # aptitude install python-pip python-dev
    # pip install virtualenv

pip3:

    $ sudo apt-get install python3-pip
    $ pip3 -V

tmux:

    to install it from source, see https://goo.gl/ZAtGhY

autojump:

    # apt-get install autojump

mc:

    # apt-get install mc

git:

    # apt-get install git

htop:

    # apt-get install htop

copy your own settings
----------------------
In this repo I collected my dotfiles. It's time to copy them to the server.
For this, you can use FileZilla for instance with the SFTP protocol.

mc: make backspace jump to parent dir
-------------------------------------

    $ cd ~/.config/mc
    $ cp /etc/mc/mc.keymap .
    $ vi mc.keymap

Uncomment and edit this line:

    CdParentSmart = backspace

add a swap file (optional)
--------------------------
Once I bought a VPS with MongoDB preinstalled. This machine had 512 MB RAM
with no swap at all. It was not enough for MongoDB and when I tried to import
a dump with `mongorestore`, the server crashed, ran out of memory. After
adding a swap file MongoDB worked well.

So, how to add a swap file? For this I used this excellent blog post:
* http://www.cyberciti.biz/faq/linux-add-a-swap-file-howto/

Again, I just some up the necessary steps here.

Switch to root and create a file that you want to use as a swap file:

    # cd /
    # dd if=/dev/zero of=/swapfile1 bs=1G count=2
    # ls -al

The file is in the root folder (`/`) and its size is 2 GB (2048 MB).

Secure the swap file:

    # chown root:root /swapfile1
    # chmod 0600 /swapfile1

Make it a swap file (so far it was just a big, but normal file):

    # mkswap /swapfile1

Activate it:

    # swapon /swapfile1

If you reboot your machine, it's off (not activated). To make it permanent,
add it to your `/etc/fstab`:

    # vi /etc/fstab

And add this line:

    /swapfile1 none swap sw 0 0

Save and just to test if everything is OK, reboot your machine.

Verify if swap is active:

    $ free

Or:

    $ htop
