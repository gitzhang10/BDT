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

# Update IP addresses to all remote AWS servers 
 rm tmp_hosts.config
 i=0; while [ $i -le $(( N-1 )) ]; do
   echo $i ${priIPsVar[$i]} ${pubIPsVar[$i]} $(( $((200 * $i)) + 10000 )) >> tmp_hosts.config
   i=$(( i+1 ))
 done
 wait
 i=0; while [ $i -le $(( N-1 )) ]; do
   ssh -o "StrictHostKeyChecking no" -i "/home/vagrant/.ssh/dumbo.pem" vagrant@${pubIPsVar[i]} "rm /home/vagrant/BDT/hosts.config"
   scp -i "/home/vagrant/.ssh/dumbo.pem" tmp_hosts.config vagrant@${pubIPsVar[i]}:/home/vagrant/BDT/hosts.config &
   i=$(( i+1 ))
 done
 wait
 # Start Protocols at all remote AWS servers
 i=0; while [ $i -le $(( N-1 )) ]; do   ssh -i "/home/vagrant/.ssh/dumbo.pem" vagrant@${pubIPsVar[i]} "export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib; export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib; cd BDT; nohup python3 run_socket_node.py --sid 'sidA' --id $i --N $N --f $(( (N-1)/3 )) --B 1000 --K 20 --S 50 --T 2 --P "dumbo" --F 1000000 > node-$i.out" &   i=$(( i+1 )); done
 wait
 # Download logs from all remote AWS servers to your local PC
 i=0
 while [ $i -le $(( N-1 )) ]
 do
   scp -i "/home/vagrant/.ssh/dumbo.pem" vagrant@${pubIPsVar[i]}:/home/vagrant/BDT/log/node-$i.log node-$i.log &
   i=$(( i+1 ))
 done
