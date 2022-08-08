COMPILE_DOCKER="true"

minikube delete

minikube start --driver=hyperv --memory=16g --cpus=8 --disk-size=30g

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

export HOST_PROJECTS_FOLDER=/c/Users/vegav/Projects
export MINIKUBE_PROJECTS_FOLDER=/home/docker

minikube addons enable ingress

if [[ $COMPILE_DOCKER = "true" ]]
then
    minikube ssh "git clone https://github.com/vmartinvega-pivotal/jenkins-ci"
fi

# Compile the agents
export JNLP_AGENT_FOLDER=jnlp-agent
if [[ $COMPILE_DOCKER = "true" ]]
then
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/agents/$JNLP_AGENT_FOLDER/ && docker build -t vmartinvega/jnlp-agent ."
fi

export MAVEN_JNLP_AGENT_FOLDER=maven-jnlp-agent
if [[ $COMPILE_DOCKER = "true" ]]
then
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/agents/$MAVEN_JNLP_AGENT_FOLDER/ && docker build -t vmartinvega/maven-jnlp-agent ."
fi

# Build jenkins
if [[ $COMPILE_DOCKER = "true" ]]
then
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/jenkins && docker build -t vmartinvega/jenkins ."
fi
KUBECONFIG_FILE_BYTES=$(cat ${HOME}/.kube/config | base64 --wrap=0)
sed "s/KUBERNETES_URL/https:\/\/$MINIKUBE_IP:8443/g" $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-conf-template.yaml > $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file
sed "s/KUBECONFIG_FILE_BYTES/$KUBECONFIG_FILE_BYTES/g" $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file > $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-conf.yaml
rm $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file

kubectl create configmap jenkins-conf --from-file=$HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-conf.yaml

kubectl create -f $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-deployment-single.yaml

echo ""
echo ""
echo "Installed Jenkis at: http://${MINIKUBE_IP}:32000 or http://jenkins.local.nip.io"
echo ""
echo ""
echo "Add the following entries to the file /etc/hosts"
echo ""
echo "${MINIKUBE_IP} gitlab.local.nip.io"