
### How to use
##### Layer1: Build base centos images
cd centos-base
docker-compose build
##### Layer2: Build jenkins images  
cd ../jen-centos76
docker-compose build
docker-compose up -d
ssh -p 2222 root@localhost

lts version: jenkins-2.277.1 used




