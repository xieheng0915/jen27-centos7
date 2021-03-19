FROM centos-base-img:1.0

USER root

RUN yum install -y binutils curl net-tools  gawk perl  sudo wget nano tar vim traceroute bind-utils iproute net-tools tcpdump  telnet ; 
RUN mkdir /var/run/sshd; 
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; echo "sshd option configured"

# ----------------------------------------------------------------------
# SSH Server

ARG SSH_PASSWD=root:Docker!
ARG SSH_PORT=2222

# sshd
RUN yum -y -c /etc/yum.custom.repos.d/yum.custom.conf --enablerepo=remi install \
    openssh-server
COPY ./config/sshd_config /etc/ssh/
RUN sed -i "s/SSH_PORT/${SSH_PORT}/g" /etc/ssh/sshd_config 
RUN echo "${SSH_PASSWD}" | chpasswd root
RUN usermod -d /root root

ADD ./config/ssh_setup.sh /tmp
RUN chmod u+x /tmp/ssh_setup.sh && \
    /tmp/ssh_setup.sh && \
    rm -rf /tmp/ssh_setup.sh

# Expose
EXPOSE ${SSH_PORT}


# ----------------------------------------------------------------------
# SSH Client

RUN yum -y -c /etc/yum.custom.repos.d/yum.custom.conf --enablerepo=remi install \
    openssh-clients

# ----------------------------------------------------------------------


#----------jenkins-------------------------------------------------
RUN yum update -y && yum install -y epel-release && yum install -y git curl dpkg java java-devel unzip which && yum clean all
ENV JAVA_HOME /etc/alternatives/jre_openjdk

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref

ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV REF $REF

# Jenkins is run with user `jenkins`, uid = 1000

RUN mkdir -p $JENKINS_HOME \
  && chown -R ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
RUN chown -R ${user}:${group} /var/jenkins_home

RUN echo 'jenkins:jenkins' | chpasswd jenkins
RUN usermod -d $JENKINS_HOME ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
RUN mkdir -p ${REF}/init.groovy.d

# Use tini as subreaper in Docker container to adopt zombie processes
ARG TINI_VERSION=v0.16.1
COPY ./config/tini_pub.gpg ${JENKINS_HOME}/tini_pub.gpg
RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini \
  && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc \
  && gpg --no-tty --import ${JENKINS_HOME}/tini_pub.gpg \
  && gpg --verify /sbin/tini.asc \
  && rm -rf /sbin/tini.asc /root/.gnupg \
  && chmod +x /sbin/tini

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
#ENV JENKINS_VERSION ${JENKINS_VERSION:-2.121.1}
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.277.1}

# jenkins.war checksum, download will be validated using it
# don't forget to change the checksum when jenkins version changed, for jenkins.war verification code, try: https://updates.jenkins-ci.org/download/war/
#ARG JENKINS_SHA=5bb075b81a3929ceada4e960049e37df5f15a1e3cfc9dc24d749858e70b48919
ARG JENKINS_SHA=399741db1152ee7bbe8dc08e0972efa0b128a1b55a0f8b10c087fefeec66d151


ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war


RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" "$REF"

# Add env para refering to docker hub
ARG PLUGIN_CLI_URL=https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.8.0/jenkins-plugin-manager-2.8.0.jar

# sonar scanner
RUN mkdir /usr/share/sonar
ADD config/sonar-scanner-cli-4.3.0.2102-linux.zip /usr/share/sonar
RUN unzip -d /usr/share/sonar /usr/share/sonar/sonar-scanner-cli-4.3.0.2102-linux.zip
ENV PATH $PATH:/usr/share/sonar/sonar-scanner-4.3.0.2102-linux/bin



# for main web interface:
EXPOSE ${http_port}

# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG=$JENKINS_HOME/copy_reference_file.log



#USER ${user}

COPY ./config/jenkins-support /usr/local/bin/jenkins-support
COPY ./config/jenkins.sh /usr/local/bin/jenkins.sh
COPY ./config/tini-shim.sh /bin/tini

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup $REF/plugins from a support bundle
COPY ./config/plugins.sh /usr/local/bin/plugins.sh
COPY ./config/install-plugins.sh /usr/local/bin/install-plugins.sh

ADD ./config/start-up.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/start-up.sh
ENTRYPOINT ["/usr/local/bin/start-up.sh"]

