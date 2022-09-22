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

# kill all server
 i=0; while [ $i -le $(( N-1 )) ]; do
 ssh -o "StrictHostKeyChecking no" -i "/home/vagrant/.ssh/dumbo.pem" vagrant@${pubIPsVar[i]} "killall python3" &
 i=$(( i+1 ))
 done