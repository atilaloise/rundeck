FROM debian:stretch

ENV SERVER_URL=https://localhost:4443 \
    RUNDECK_STORAGE_PROVIDER=file \
    RUNDECK_PROJECT_STORAGE_TYPE=file \
    NO_LOCAL_MYSQL=false \
    LOGIN_MODULE=RDpropertyfilelogin \
    JAAS_CONF_FILE=jaas-loginmodule.conf \
    KEYSTORE_PASS=adminadmin \
    TRUSTSTORE_PASS=adminadmin \
    CLUSTER_MODE=false

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list && \
    apt-get -qq update && \
    apt-get -qqy install -t stretch-backports --no-install-recommends bash openjdk-8-jre-headless ca-certificates-java supervisor procps sudo ca-certificates openssh-client mysql-client pwgen curl git uuid-runtime parallel jq locales && \
    cd /tmp/ && \
    curl -Lo /tmp/rundeck.deb https://dl.bintray.com/rundeck/rundeck-deb/rundeck_3.3.5.20201019-1_all.deb && \
    echo '3176e3274ad1e61fcaf36159669a9b335dce0136ab83ac91930a60c2e546673e  rundeck.deb' > /tmp/rundeck.sig && \
    shasum -a256 -c /tmp/rundeck.sig && \
    curl -Lo /tmp/rundeck-cli.deb https://dl.bintray.com/rundeck/rundeck-deb/rundeck-cli_1.3.4-1_all.deb && \
    echo '9b3556bff09a7b8dc00f99586ce740327a5e459d121b9a7882163c22e7c6b9cc  rundeck-cli.deb' > /tmp/rundeck-cli.sig && \
    shasum -a256 -c /tmp/rundeck-cli.sig && \
    cd - && \
    dpkg -i /tmp/rundeck*.deb && rm /tmp/rundeck*.deb && \
    mkdir -p /tmp/rundeck && \
    chown rundeck:rundeck /tmp/rundeck && \
    mkdir -p /var/lib/rundeck/.ssh && \
    chown rundeck:rundeck /var/lib/rundeck/.ssh && \
    sed -i "s/export RDECK_JVM=\"/export RDECK_JVM=\"\${RDECK_JVM} /" /etc/rundeck/profile && \
    cd - && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get -qq update && \
    apt-get -qqy install --no-install-recommends gnupg dirmngr && \
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    apt-get update && \
    apt-get -qqy install --no-install-recommends python-pip sshpass nmap python3 ansible && \
    apt-get clean

ADD content/ /

RUN chmod u+x /opt/run && \
    mkdir -p /var/log/supervisor && mkdir -p /opt/supervisor && \
    chmod u+x /opt/supervisor/rundeck && chmod u+x /opt/supervisor/fatalservicelistener

EXPOSE 4440 4443

VOLUME  ["/etc/rundeck", "/var/rundeck", "/var/log/rundeck", "/opt/rundeck-plugins", "/var/lib/rundeck/logs", "/var/lib/rundeck/var/storage"]

ENTRYPOINT ["/opt/run"]