FROM jenkins/jenkins:latest

# Distributed Builds plugins
RUN jenkins-plugin-cli ssh-slaves

# install Notifications and Publishing plugins
RUN jenkins-plugin-cli email-ext
RUN jenkins-plugin-cli mailer
RUN jenkins-plugin-cli slack

# Artifacts
RUN jenkins-plugin-cli htmlpublisher

# UI
RUN jenkins-plugin-cli greenballs
RUN jenkins-plugin-cli simple-theme-plugin

# Scaling
RUN jenkins-plugin-cli kubernetes

# Recommended plugins
RUN jenkins-plugin-cli branch-api
RUN jenkins-plugin-cli credentials
RUN jenkins-plugin-cli credentials-binding
RUN jenkins-plugin-cli github-api
RUN jenkins-plugin-cli kubernetes-client-api
RUN jenkins-plugin-cli ldap
RUN jenkins-plugin-cli workflow-scm-step
RUN jenkins-plugin-cli workflow-cps-global-lib
RUN jenkins-plugin-cli timestamper
RUN jenkins-plugin-cli locale
RUN jenkins-plugin-cli ant
RUN jenkins-plugin-cli build-timeout
RUN jenkins-plugin-cli command-launcher
RUN jenkins-plugin-cli github-branch-source
RUN jenkins-plugin-cli gradle
RUN jenkins-plugin-cli kubernetes-cd
RUN jenkins-plugin-cli matrix-auth
RUN jenkins-plugin-cli jdk-tool
RUN jenkins-plugin-cli antisamy-markup-formatter
RUN jenkins-plugin-cli pam-auth
RUN jenkins-plugin-cli workflow-aggregator
RUN jenkins-plugin-cli pipeline-github-lib
RUN jenkins-plugin-cli ssh-slaves
RUN jenkins-plugin-cli subversion
RUN jenkins-plugin-cli ws-cleanup
RUN jenkins-plugin-cli configuration-as-code
RUN jenkins-plugin-cli configuration-as-code-support

# install Maven
USER root
RUN apt-get update && apt-get install -y maven
USER jenkins
