INSTALL_AGENTS="true"

minikube delete

minikube start --driver=virtualbox --memory=16g --cpus=8 --disk-size=30g

# Gets the path for the different certificates to later change those values to embed certificates
# inside kubeconfig
MINIKUBE_CLIENT_CERTIFICATE=$(kubectl config view -o jsonpath='{.users[?(@.name == "minikube")].user.client-certificate}')
MINIKUBE_CLIENT_KEY=$(kubectl config view -o jsonpath='{.users[?(@.name == "minikube")].user.client-key}')
CA_CERTIFICATE=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "minikube")].cluster.certificate-authority}')
KUBERNETES_URL=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "minikube")].cluster.server}')
MINIKUBE_IP=$(minikube ip)

# Update the certs path in the kubeconfig file with embed certificates
# this is needed to configure the kubernetes plugin for jenkins
kubectl config set-credentials minikube --client-certificate=$MINIKUBE_CLIENT_CERTIFICATE --embed-certs=true
kubectl config set-credentials minikube --client-key=$MINIKUBE_CLIENT_KEY  --embed-certs=true
kubectl config set-cluster minikube --certificate-authority=$CA_CERTIFICATE --embed-certs=true

# Configure minikube
HOST_PROJECTS_FOLDER=/home/vicente/Projects
MINIKUBE_PROJECTS_FOLDER=/hosthome/vicente/Projects

if [[ $INSTALL_AGENTS = "true" ]]
then
    JNLP_AGENT_FOLDER=jnlp-agent
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/$JNLP_AGENT_FOLDER/ && docker build -t c3alm-sgt/jnlp-agent ."

    MAVEN_JNLP_AGENT_FOLDER=maven-jnlp-agent
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/$MAVEN_JNLP_AGENT_FOLDER/ && docker build -t c3alm-sgt/maven-jnlp-agent ."
fi

minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/jenkins && docker build -t c3alm-sgt/jenkins ."
kubectl create -f $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-deployment.yaml
./kubernetes/wait-until-pods-ready.sh 60 5
KUBECONFIG_FILE_BYTES=$(cat ${HOME}/.kube/config | base64 --wrap=0)
sed "s/KUBERNETES_URL/https:\/\/$MINIKUBE_IP:8443/g" $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-conf-template.yaml > $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file
sed "s/KUBECONFIG_FILE_BYTES/$KUBECONFIG_FILE_BYTES/g" $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file > $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-conf.yaml

rm $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file

echo "Installed Jenkis at: http://${MINIKUBE_IP}:32000"