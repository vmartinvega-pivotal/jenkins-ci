FROM jenkins/jenkins:latest

# Distributed Builds plugins
RUN /usr/local/bin/install-plugins.sh ssh-slaves

# install Notifications and Publishing plugins
RUN /usr/local/bin/install-plugins.sh email-ext
RUN /usr/local/bin/install-plugins.sh mailer
RUN /usr/local/bin/install-plugins.sh slack

# Artifacts
RUN /usr/local/bin/install-plugins.sh htmlpublisher

# UI
RUN /usr/local/bin/install-plugins.sh greenballs
RUN /usr/local/bin/install-plugins.sh simple-theme-plugin

# Scaling
RUN /usr/local/bin/install-plugins.sh kubernetes

# Recommended plugins
RUN /usr/local/bin/install-plugins.sh branch-api
RUN /usr/local/bin/install-plugins.sh credentials
RUN /usr/local/bin/install-plugins.sh credentials-binding
RUN /usr/local/bin/install-plugins.sh github-api
RUN /usr/local/bin/install-plugins.sh kubernetes-client-api
RUN /usr/local/bin/install-plugins.sh ldap
RUN /usr/local/bin/install-plugins.sh workflow-scm-step
RUN /usr/local/bin/install-plugins.sh workflow-cps-global-lib
RUN /usr/local/bin/install-plugins.sh timestamper
RUN /usr/local/bin/install-plugins.sh locale
RUN /usr/local/bin/install-plugins.sh ant
RUN /usr/local/bin/install-plugins.sh build-timeout
RUN /usr/local/bin/install-plugins.sh command-launcher
RUN /usr/local/bin/install-plugins.sh github-branch-source
RUN /usr/local/bin/install-plugins.sh gradle
RUN /usr/local/bin/install-plugins.sh kubernetes-cd
RUN /usr/local/bin/install-plugins.sh matrix-auth
RUN /usr/local/bin/install-plugins.sh jdk-tool
RUN /usr/local/bin/install-plugins.sh antisamy-markup-formatter
RUN /usr/local/bin/install-plugins.sh pam-auth
RUN /usr/local/bin/install-plugins.sh workflow-aggregator
RUN /usr/local/bin/install-plugins.sh pipeline-github-lib
RUN /usr/local/bin/install-plugins.sh ssh-slaves
RUN /usr/local/bin/install-plugins.sh subversion
RUN /usr/local/bin/install-plugins.sh ws-cleanup
RUN /usr/local/bin/install-plugins.sh configuration-as-code
RUN /usr/local/bin/install-plugins.sh configuration-as-code-support
RUN /usr/local/bin/install-plugins.sh statistics-gatherer

# install Maven
USER root
RUN apt-get update && apt-get install -y maven
USER jenkins
