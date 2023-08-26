# Originally from
# https://github.com/jjethwa/rundeck

FROM debian:bullseye

ENV SERVER_URL=https://localhost:4443 \
    RUNDECK_STORAGE_PROVIDER=db \
    NO_LOCAL_MYSQL=false \
    LOGIN_MODULE=RDpropertyfilelogin \
    JAAS_CONF_FILE=jaas-loginmodule.conf \
    KEYSTORE_PASS=adminadmin \
    TRUSTSTORE_PASS=adminadmin \
    CLUSTER_MODE=false

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb http://ftp.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list && \
    apt-get -qq update && \
    apt-get -qqy install -t bullseye-backports --no-install-recommends apt-transport-https curl ca-certificates && \
    curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version=10.5 && \
    apt-get -qqy install -t bullseye-backports --no-install-recommends bash openjdk-11-jre-headless ca-certificates-java supervisor procps sudo openssh-client mariadb-client postgresql-client pwgen git uuid-runtime parallel jq libxml2-utils html2text unzip && \
    curl -s https://packagecloud.io/install/repositories/pagerduty/rundeck/script.deb.sh | os=any dist=any bash && \
    echo "deb http://deb.debian.org/debian stable main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ stable-security main contrib non-free" >> /etc/apt/sources.list &&  \
    cat /etc/apt/sources.list && \
	apt-get -y update && \
    apt-get -y install --no-install-recommends gnupg && \
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && \
    apt-get -qq --allow-unauthenticated update && \
    apt-get -qqy install --allow-unauthenticated ansible  && \
    apt-get -qqy install --no-install-recommends python3-pip sshpass nmap && \
    apt-get -qqy install rundeck rundeck-cli && \
    mkdir -p /tmp/rundeck && \
    chown rundeck:rundeck /tmp/rundeck && \
    mkdir -p /var/lib/rundeck/.ssh && \
    chown rundeck:rundeck /var/lib/rundeck/.ssh && \
    sed -i "s/export RDECK_JVM=\"/export RDECK_JVM=\"\${RDECK_JVM} /" /etc/rundeck/profile && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD content/ /
RUN chmod u+x /opt/run && \
    mkdir -p /var/log/supervisor && mkdir -p /opt/supervisor && \
    chmod u+x /opt/supervisor/rundeck && chmod u+x /opt/supervisor/fatalservicelistener

EXPOSE 4440 4443

VOLUME  ["/etc/rundeck", "/var/rundeck", "/var/log/rundeck", "/var/lib/rundeck/logs", "/var/lib/rundeck/var/storage", "/var/lib/rundeck/projects", "/var/lib/rundeck/libext"]

ENTRYPOINT ["/opt/run"]