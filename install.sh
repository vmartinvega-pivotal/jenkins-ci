minikube delete

minikube start --driver=virtualbox --memory=16g --cpus=8 --disk-size=30g

# Gets the path for the different certificates to later change those values to embed certificates
# inside kubeconfig
export MINIKUBE_CLIENT_CERTIFICATE=$(kubectl config view -o jsonpath='{.users[?(@.name == "minikube")].user.client-certificate}')
export MINIKUBE_CLIENT_KEY=$(kubectl config view -o jsonpath='{.users[?(@.name == "minikube")].user.client-key}')
export CA_CERTIFICATE=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "minikube")].cluster.certificate-authority}')
export KUBERNETES_URL=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "minikube")].cluster.server}')
export MINIKUBE_IP=$(minikube ip)

# Update the certs path in the kubeconfig file with embed certificates
# this is needed to configure the kubernetes plugin for jenkins
kubectl config set-credentials minikube --client-certificate=$MINIKUBE_CLIENT_CERTIFICATE --embed-certs=true
kubectl config set-credentials minikube --client-key=$MINIKUBE_CLIENT_KEY  --embed-certs=true
kubectl config set-cluster minikube --certificate-authority=$CA_CERTIFICATE --embed-certs=true

export HOST_PROJECTS_FOLDER=/home/vicente/Projects
export MINIKUBE_PROJECTS_FOLDER=/hosthome/vicente/Projects

# Install gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab/values-minikube-minimum.yaml > $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab/output.file
helm install -f $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab/output.file gitlab gitlab/gitlab
rm $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab/output.file
minikube addons enable ingress

# Compile the agents
export JNLP_AGENT_FOLDER=jnlp-agent
minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/agents/$JNLP_AGENT_FOLDER/ && docker build -t vmartinvega/jnlp-agent ."

export MAVEN_JNLP_AGENT_FOLDER=maven-jnlp-agent
minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/agents/$MAVEN_JNLP_AGENT_FOLDER/ && docker build -t vmartinvega/maven-jnlp-agent ."

# Build fluentd
minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/fluentd-kubernetes-daemonset-http && docker build -t vmartinvega/fluentd-kubernetes-daemonset:v1-debian-http ."

# Build watcher
minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/spring-boot-watcher-service && docker build -t vmartinvega/spring-boot-watcher-service ."

# Build jenkins
minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/jenkins && docker build -t vmartinvega/jenkins ."
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' ; echo)
sed "s/GITLAB_SECRET/$GITLAB_PASSWORD/g" $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-deployment-template.yaml > $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jjenkins-deployment.yaml
kubectl create -f $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-deployment.yaml

./kubernetes/wait-until-pods-ready.sh 60 5
KUBECONFIG_FILE_BYTES=$(cat ${HOME}/.kube/config | base64 --wrap=0)
sed "s/KUBERNETES_URL/https:\/\/$MINIKUBE_IP:8443/g" $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-conf-template.yaml > $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file
sed "s/KUBECONFIG_FILE_BYTES/$KUBECONFIG_FILE_BYTES/g" $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file > $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-conf.yaml
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo)

rm $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file

kubectl create -f $HOST_PROJECTS_FOLDER/spring-boot-echo-service/kubernetes/deployment.yaml

echo ""
echo ""
echo "Installed Jenkis at: http://${MINIKUBE_IP}:32000"
echo ""
echo ""