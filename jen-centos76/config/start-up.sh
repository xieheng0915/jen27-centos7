#!/bin/bash

/usr/sbin/sshd -D  &

chown -R jenkins:jenkins /var/jenkins_home
chown -R jenkins:jenkins /usr/local/bin/*
chown -R jenkins:jenkins /usr/share/jenkins
PATH=$PATH:/usr/share/sonar/sonar-scanner-4.3.0.2102-linux/bin

su - jenkins -c "/sbin/tini -- /usr/local/bin/jenkins.sh"


