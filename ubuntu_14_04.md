Digital Ocean (notes and dotfiles)
==================================

Here I sum up how to configure a VPS (virtual private server) running
**Ubuntu** GNU/Linux **14.04 LTS**. I tried it with Digital Ocean, but
it must be the same with others too, like Linode, etc.

As a basis, I used the following blog posts:
* [Initial Server Setup with Ubuntu 12.04](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-12-04)
* [How To Set Up Your Linode For Maximum Awesomeness](http://feross.org/how-to-setup-your-linode/)

For a detailed guide, read those blog posts. Here I just sum up the steps shortly.

Again, I tried these steps on an Ubuntu **14.04** machine.

start
-----
You bought your VPS. You get an email that contains info how to log in.
Log in as root:

    $ ssh root@1.2.3.4

You'll have to change your password.

change hostname (optional)
--------------------------
When creating a new VPS with Digital Ocean, you can give a name to your server.
Later you can rename it to something else:

    # echo "do-test" > /etc/hostname
    # hostname -F /etc/hostname

Verification:

    $ hostname

new user
--------
Create a new user:

    # adduser demo

Provide the password of the user (the other pieces of info are not important).

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
    # date

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

If you use a newer version of Ubuntu, this reload method may not work. In that
case try this:

    $ sudo systemctl restart ssh

test SSH settings
-----------------
*!!! Don't log out as root yet !!!* Try to log in as a normal user:

    $ ssh -p 1234 demo@1.2.3.4

Since the SSH port was moved in this example from the default, we need to
specify the new port (`-p` option).

Once in, test if you can sudo:

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

Save and run this script, and then *test again if you can log in*! Open a new
terminal, don't close the current one, and try to log in:

    $ ssh -p 1234 demo@1.2.3.4

If it works, then your firewall settings are good, your SSH port is open. But,
if your firewall is not configured properly and your SSH port is closed, then
once you log out, you locked yourself out. So that's why we verified again
if we can still log in.

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
Or, even simpler, just clone this repo to your server. See the content
of the `home/demo` folder.

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

Again, I just sum up the necessary steps here.

Switch to root and create a file that you want to use as a swap file:

    # cd /
    # dd if=/dev/zero of=/swapfile1 bs=1M count=4096
    # ls -al

The file is in the root folder (`/`) and its size is 4096 MB, i.e. 4 GB.

Secure the swap file:

    # chown root:root /swapfile1
    # chmod 0600 /swapfile1
    # ls -al

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

create a bigger swap file (optional)
------------------------------------
If the swap file is too small and you want to create a bigger one, then
first you need to switch it off:

    # swapoff /swapfile1

Make sure that it's off using the command `free` or `htop`. Then follow
the steps in the previous paragraph but this time create a bigger swap file.

send email from the terminal (optional)
---------------------------------------
I have several scripts running on my DO machine. Sometimes I would like to get
an email notification when one of them is finished. Install these packages:

    $ sudo aptitude install sendmail
    $ sudo aptitude install mailutils

Now try to send emails to you. With subject and body:

    echo "this is the body" | mail -s "this is the subject" "your@email.address"

Or with just a subject:

    mailx -s "This is all she wrote" < /dev/null "your@email.address"

I sent my test emails to my Gmail address and they landed in the Spam folder.

You may have the problem that sending emails this way takes a lot of time,
around a minute or so. To speed things up, edit the file `/etc/hosts` and edit
the beginning of the file. My new content looks like this:

    127.0.0.1    localhost localhost.localdomain do-test
    127.0.1.1    do-test

Where `do-test` is the hostname of my DO machine. After this restart sendmail:

    $ sudo /etc/init.d/sendmail restart

Now if you try to send emails, they will be delivered immediately. But they still land
in your Spam folder (if you use Gmail). Here is how to have them in your Inbox:
find the email in your Spam folder, open it, and on the right side select
"Filter messages like this". Here you can select "Never send it to Spam". Now
they will arrive at your Inbox.

Troubleshooting
===============

ssh login is very slow
----------------------
On my Digital Ocean VPS ssh connection has become very slow. After typing my password
I had to wait a minute or two to get the prompt. Here is a solution: edit the file
`/etc/ssh/sshd_config` and uncomment these two lines (by default they are in comments):

    GSSAPIAuthentication no
    GSSAPICleanupCredentials yes

the mongod process crashed
--------------------------
I have the cheapest Digital Ocean VPS that has only 512 MB RAM. For MongoDB it's very
little... First I created a swap file whose size was 2 GB. It was enough for a while
but as my database grew bigger and bigger, MongoDB required more and more RAM and once
it ran out of memory. I just noticed that MongoDB stopped :( In its log file
(`/var/log/mongodb/mongod.log`) I didn't find any error. It turned out that the mongod
process was killed by the OS and the error message about it can be found in the file
`/var/log/syslog`. The swap file got full and the OS killed the mongod process.

As a temporary solution, I increased the size of the swap file from 2 GB to 4 GB. It
will work for a while but sooner or later I will have to move to a VPS that has much
more RAM.
