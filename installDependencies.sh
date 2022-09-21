#!/bin/sh

cd ~
sudo apt-get update
sudo apt-get -y install python3
sudo apt-get -y install python3-pip
sudo apt-get -y install python3-dev
sudo apt-get -y install make
sudo apt-get -y install flex
sudo apt-get -y install bison
sudo apt-get -y install libgmp-dev
sudo apt-get -y install libmpc-dev
sudo apt-get -y install libssl-dev
python3 -m pip install --upgrade pip
sudo pip3 install pycrypto
sudo pip3 install ecdsa
sudo pip3 install zfec
sudo pip3 install gipc
sudo pip3 install pysocks
sudo pip3 install gevent
sudo pip3 install coincurve
sudo pip3 install numpy
sudo pip3 install setuptools
sudo pip3 install gmpy2

wget https://crypto.stanford.edu/pbc/files/pbc-0.5.14.tar.gz
tar -xvf pbc-0.5.14.tar.gz
cd pbc-0.5.14
sudo ./configure
sudo make
sudo make install
cd ~
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

git clone https://github.com/JHUISI/charm.git
cd charm
sudo ./configure.sh
sudo make
sudo make install
