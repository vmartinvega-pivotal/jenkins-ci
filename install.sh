INSTALL_AGENTS="true"
INSTALL_GITLAB="true"

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

if [[ $INSTALL_AGENTS = "true" ]]
then
    export JNLP_AGENT_FOLDER=jnlp-agent
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/agents/$JNLP_AGENT_FOLDER/ && docker build -t c3alm-sgt/jnlp-agent ."

    export MAVEN_JNLP_AGENT_FOLDER=maven-jnlp-agent
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/agents/$MAVEN_JNLP_AGENT_FOLDER/ && docker build -t c3alm-sgt/maven-jnlp-agent ."
fi

minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-ci/jenkins && docker build -t c3alm-sgt/jenkins ."
kubectl create -f $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-deployment.yaml
./kubernetes/wait-until-pods-ready.sh 60 5
KUBECONFIG_FILE_BYTES=$(cat ${HOME}/.kube/config | base64 --wrap=0)
sed "s/KUBERNETES_URL/https:\/\/$MINIKUBE_IP:8443/g" $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-conf-template.yaml > $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file
sed "s/KUBECONFIG_FILE_BYTES/$KUBECONFIG_FILE_BYTES/g" $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file > $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/jenkins-conf.yaml

rm $HOST_PROJECTS_FOLDER/jenkins-ci/jenkins/output.file

if [[ $INSTALL_GITLAB = "true" ]]
then
    helm repo add gitlab https://charts.gitlab.io/
    helm repo update
    sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab/values-minikube-minimum.yaml > $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab/output.file
    helm install -f $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab/output.file gitlab gitlab/gitlab
    rm $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab/output.file
    minikube addons enable ingress
    kubectl get secret gitlab-wildcard-tls-ca -ojsonpath='{.data.cfssl_ca}' | base64 --decode > $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab.local.nip.io.ca.pem
    openssl x509 -in $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab.local.nip.io.ca.pem -inform PEM -out $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab.local.nip.io.ca.crt
    if [ -d /usr/share/ca-certificates/gitlab ]; then
        sudo rm -Rf /usr/share/ca-certificates/gitlab
    fi
    sudo mkdir /usr/share/ca-certificates/gitlab
    sudo cp $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab.local.nip.io.ca.crt /usr/share/ca-certificates/gitlab/gitlab.local.nip.io.ca.crt
    rm $HOST_PROJECTS_FOLDER/jenkins-ci/gitlab.local.nip.io.ca.crt 
    sudo dpkg-reconfigure ca-certificates
    sudo update-ca-certificates
fi

echo ""
echo ""
echo "Installed Jenkis at: http://${MINIKUBE_IP}:32000"
echo ""
echo ""
echo "Gitlab root password: "
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo