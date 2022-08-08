FROM jenkins/jenkins:latest

# Distributed Builds plugins
RUN jenkins-plugin-cli --plugins ssh-slaves

# install Notifications and Publishing plugins
RUN jenkins-plugin-cli --plugins email-ext
RUN jenkins-plugin-cli --plugins mailer
RUN jenkins-plugin-cli --plugins slack

# Artifacts
RUN jenkins-plugin-cli --plugins htmlpublisher

# UI
RUN jenkins-plugin-cli --plugins greenballs
RUN jenkins-plugin-cli --plugins simple-theme-plugin

# Scaling
RUN jenkins-plugin-cli --plugins kubernetes

# Recommended plugins
RUN jenkins-plugin-cli --plugins branch-api
RUN jenkins-plugin-cli --plugins credentials
RUN jenkins-plugin-cli --plugins credentials-binding
RUN jenkins-plugin-cli --plugins github-api
RUN jenkins-plugin-cli --plugins kubernetes-client-api
RUN jenkins-plugin-cli --plugins ldap
RUN jenkins-plugin-cli --plugins workflow-scm-step
RUN jenkins-plugin-cli --plugins workflow-cps-global-lib
RUN jenkins-plugin-cli --plugins timestamper
RUN jenkins-plugin-cli --plugins locale
RUN jenkins-plugin-cli --plugins ant
RUN jenkins-plugin-cli --plugins build-timeout
RUN jenkins-plugin-cli --plugins command-launcher
RUN jenkins-plugin-cli --plugins github-branch-source
RUN jenkins-plugin-cli --plugins gradle
RUN jenkins-plugin-cli --plugins kubernetes-cd
RUN jenkins-plugin-cli --plugins matrix-auth
RUN jenkins-plugin-cli --plugins jdk-tool
RUN jenkins-plugin-cli --plugins antisamy-markup-formatter
RUN jenkins-plugin-cli --plugins pam-auth
RUN jenkins-plugin-cli --plugins workflow-aggregator
RUN jenkins-plugin-cli --plugins pipeline-github-lib
RUN jenkins-plugin-cli --plugins ssh-slaves
RUN jenkins-plugin-cli --plugins subversion
RUN jenkins-plugin-cli --plugins ws-cleanup
RUN jenkins-plugin-cli --plugins configuration-as-code
RUN jenkins-plugin-cli --plugins configuration-as-code-support

# install Maven
USER root
RUN apt-get update && apt-get install -y maven
USER jenkins
