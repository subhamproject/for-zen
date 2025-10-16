#!/bin/bash
sudo mkdir -p /root/first
sudo mkdir -p /root/second
sudo pvcreate /dev/xvdf /dev/xvdg
sudo vgcreate first /dev/xvdf
sudo vgcreate second /dev/xvdg
sudo lvcreate -n vol -l 100%FREE first
sudo lvcreate -n vol -l 100%FREE second
sudo mkfs.ext4 /dev/first/vol
sudo mkfs.ext4 /dev/second/vol
sudo echo "/dev/first/vol /root/first ext4 defaults 0 0" >> /etc/fstab
sudo echo "/dev/second/vol /root/second ext4 defaults 0 0" >> /etc/fstab
sudo mount -a
