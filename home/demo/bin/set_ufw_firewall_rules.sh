#!/usr/bin/env bash

sudo ufw reset
sudo ufw disable

# my SSH is here (example)
sudo ufw allow 1234/tcp
# a webapp is on port 9000 (example)
sudo ufw allow 9000/tcp

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw enable

sudo ufw status verbose
