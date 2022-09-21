#!/bin/bash

# the number of remove AWS servers
N=4

# public IPs --- This is the public IPs of AWS servers
 pubIPsVar[0]='192.168.1.2'
 pubIPsVar[1]='192.168.1.3'
 pubIPsVar[2]='192.168.1.4'
 pubIPsVar[3]='192.168.1.5'
 
# private IPs --- This is the private IPs of AWS servers
 priIPsVar[0]='192.168.1.2'
 priIPsVar[1]='192.168.1.3'
 priIPsVar[2]='192.168.1.4'
 priIPsVar[3]='192.168.1.5'

# Clone code to all remote AWS servers from github
 i=0; while [ $i -le $(( N-1 )) ]; do
 ssh -o "StrictHostKeyChecking no" -i "/home/vagrant/.ssh/dumbo.pem" vagrant@${pubIPsVar[i]} "rm -rf BDT"
 ssh -i "/home/vagrant/.ssh/dumbo.pem" -o StrictHostKeyChecking=no vagrant@${pubIPsVar[i]} "git clone https://github.com/gitzhang10/BDT.git" &
 i=$(( i+1 ))
 done

# Install dependencies to all remote AWS servers from github
i=0; while [ $i -le $(( N-1 )) ]; do
ssh -i "/home/vagrant/.ssh/dumbo.pem" -o StrictHostKeyChecking=no vagrant@${pubIPsVar[i]} "cd BDT; chmod +x installDependencies.sh; ./installDependencies.sh" &
i=$(( i+1 ))
done
