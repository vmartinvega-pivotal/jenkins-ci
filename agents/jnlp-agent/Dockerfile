FROM jenkinsci/jnlp-slave:3.40-1

ARG AGENT_VERSION=c3alm-sgt/jnlp-agent:latest

ARG HTTP_PROXY
ARG HTTPS_PROXY=$HTTP_PROXY
ARG NO_PROXY=.corp

ARG JENKINS_AGENT_HOME=/home/jenkins
ARG DOCKER_SLAVE_TAG=c3alm-sgt/jnlp-agent:latest

LABEL ALM_DESCRIPTION="A basic Jenkins JNLP Slave docker image" \
    ALM_COMPONENTS="OpenJDK JRE8, sshpass, git, curl, wget, unzip" \
    ALM_IMAGE_VERSION="v1" \
    maintainer="ALM Multicloud <alm-multicloud@gruposantander.com>"


ENV JENKINS_AGENT_HOME=${JENKINS_AGENT_HOME} \
    GIT_SSL_NO_VERIFY=1 \
    GIT_TERMINAL_PROMPT=0 \
    SONAR_RUNNER_VERSION=2.4 \
    SONAR_RUNNER_HOME=/usr/share/sonar-runner \
    SONAR_USER_HOME=${JENKINS_AGENT_HOME}/.sonar \
    AGENT_HOME=/KiuwanLocalAnalyzer \
    AGENT_VERSION=${AGENT_VERSION} \
    SONAR_SCANNER_HOME=/usr/share/sonar-scanner \
    SONAR_SCANNER_VERSION=3.2.0.1227

USER root

# Installs certificates && common tools
RUN  echo "Installing alm certificates..." \
  && dpkg-reconfigure ca-certificates \
  && update-ca-certificates \
  && echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" >> /etc/apt/apt.conf \
  && apt-get -q -o Acquire::Check-Valid-Until=false update && apt-get upgrade -y \
  && DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends \
  libgdiplus libc6-dev build-essential sshpass unzip telnet zip jq \
  && apt-get -q autoclean && apt-get -q --purge -y autoremove && rm -rf /var/lib/apt/lists/* \
  && curl -L https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64 -o /usr/bin/yq \
  && chmod +x /usr/bin/yq \
  && git config --system http.sslCAPath /usr/local/share/ca-certificates/gitlab \
  && mkdir -p "${JENKINS_AGENT_HOME}/.ssh" \
  && echo "Host *\n    StrictHostKeyChecking no" >> "${JENKINS_AGENT_HOME}/.ssh/config" \
  && chown -R jenkins:jenkins "${JENKINS_AGENT_HOME}/.ssh/" 

# Installs Sonnar Runner (Sonar <= 5.7)
RUN echo "Installing Sonnar Runner... " \
  && cd /usr/share \
  && https_proxy=${HTTPS_PROXY} wget https://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/${SONAR_RUNNER_VERSION}/sonar-runner-dist-${SONAR_RUNNER_VERSION}.zip  \
  && unzip sonar-runner-dist-${SONAR_RUNNER_VERSION}.zip \
  && mv sonar-runner-${SONAR_RUNNER_VERSION} sonar-runner \
  && ln -s ${SONAR_RUNNER_HOME}/bin/sonar-runner /usr/bin/sonar-runner \
  && rm sonar-runner-dist-${SONAR_RUNNER_VERSION}.zip 

# Installs Sonnar Scanner (Sonar = 7.9)
  RUN echo "Installing Sonar Scanner... " \
  && cd /usr/share \
  && https_proxy=${HTTPS_PROXY} wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip  \
  && unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip \
  && mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux sonar-scanner \
  && ln -s ${SONAR_SCANNER_HOME}/bin/sonar-scanner /usr/bin/sonar-scanner \
  && rm sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
  
#Install Kiuwan Local Analyzer.
RUN echo "Installing Kiuwan Local Analyzer (KLA)..." \
  && mkdir -p ${AGENT_HOME}/temp \
  && curl -o /tmp/KiuwanLocalAnalyzer.zip https://www.kiuwan.com/pub/analyzer/KiuwanLocalAnalyzer.zip \
  && unzip /tmp/KiuwanLocalAnalyzer.zip -d / \
  && touch ${AGENT_HOME}/temp/agent.log \
  && chmod -R 777 ${AGENT_HOME}/temp \
  && chmod +x ${AGENT_HOME}/bin/*.sh \
  && sed -i s/proxy.host=/proxy.host=$(basename ${HTTP_PROXY} | sed 's/:.*//')/ ${AGENT_HOME}/conf/agent.properties \
  && sed -i s/proxy.port=3128/proxy.port=$(echo $HTTP_PROXY | sed 's/[^0-9]*\([0-9]\{1,\}\).*$/\1/')/ ${AGENT_HOME}/conf/agent.properties \
  && rm -rf /tmp/KiuwanLocalAnalyzer.zip \
  && echo "Changing Kiuwan directory (${AGENT_HOME}) owner..." \
  && chown -R jenkins:jenkins ${AGENT_HOME}
  
RUN mkdir -p ${SONAR_USER_HOME} \
  && chmod -R 777 ${SONAR_USER_HOME} 

USER jenkins:jenkins

VOLUME ${SONAR_USER_HOME}

