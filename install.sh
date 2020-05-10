INSTALL_JENKINS="false"
INSTALL_REGISTRY="false"
INSTALL_GITLAB="true"
INSTALL_AGENTS="false"

# Gets the path for the different certificates to later change those values to embed certificates
# inside kubeconfig
MINIKUBE_CLIENT_CERTIFICATE=$(kubectl config view -o jsonpath='{.users[?(@.name == "minikube")].user.client-certificate}')
MINIKUBE_CLIENT_KEY=$(kubectl config view -o jsonpath='{.users[?(@.name == "minikube")].user.client-key}')
CA_CERTIFICATE=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "minikube")].cluster.certificate-authority}')
KUBERNETES_URL=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "minikube")].cluster.server}')

# Update the certs path in the kubeconfig file with embed certificates
# this is needed to configure the kubernetes plugin for jenkins
kubectl config set-credentials minikube --client-certificate=$MINIKUBE_CLIENT_CERTIFICATE --embed-certs=true
kubectl config set-credentials minikube --client-key=$MINIKUBE_CLIENT_KEY  --embed-certs=true
kubectl config set-cluster minikube --certificate-authority=$CA_CERTIFICATE --embed-certs=true

# Configure minikube
TEMP_FOLDER=/minikube-install
HOST_PROJECTS_FOLDER=/home/vicente/Documents/Projects
MINIKUBE_PROJECTS_FOLDER=/hosthome/vicente/Documents/Projects

rm -Rf $HOST_PROJECTS_FOLDER/$TEMP_FOLDER
mkdir $HOST_PROJECTS_FOLDER/$TEMP_FOLDER

cd $HOST_PROJECTS_FOLDER/$TEMP_FOLDER && git clone https://github.com/kameshsampath/minikube-helpers 

if [[ $INSTALL_REGISTRY = "true" ]]
then
    minikube addons enable registry
    cd $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/minikube-helpers/registry && \
    kubectl apply -n kube-system \
        -f registry-aliases-config.yaml \
        -f node-etc-hosts-update.yaml \
        -f patch-coredns-job.yaml
    CLUSTER_IP_REGISTRY=$(kubectl -n kube-system get svc registry -o jsonpath='{.spec.clusterIP}')
fi

cd $HOST_PROJECTS_FOLDER/$TEMP_FOLDER && git clone https://github.com/vmartinvega-pivotal/jenkins-pipeline-k8s-test

if [[ $INSTALL_GITLAB = "true" ]]
then
    helm repo add gitlab https://charts.gitlab.io/
    helm repo update
    # Get minikube ip
    MINIKUBE_IP=$(minikube ip)
    sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/jenkins-pipeline-k8s-test/values-minikube-minimum.yaml > $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/jenkins-pipeline-k8s-test/output.file
    helm install -f $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/jenkins-pipeline-k8s-test/output.file gitlab gitlab/gitlab
    rm $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/jenkins-pipeline-k8s-test/output.file
    minikube addons enable ingress
    echo "Gitlab root password: "
    kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
    kubectl get secret gitlab-wildcard-tls-ca -ojsonpath='{.data.cfssl_ca}' | base64 --decode > $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/jenkins-pipeline-k8s-test/gitlab.local.nip.io.ca.pem
    openssl x509 -in $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/jenkins-pipeline-k8s-test/gitlab.local.nip.io.ca.pem -inform PEM -out $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/jenkins-pipeline-k8s-test/gitlab.local.nip.io.ca.crt
    $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/jenkins-pipeline-k8s-test/gitlab.local.nip.io.ca.crt
    if [ -d /usr/share/ca-certificates/gitlab ]; then
        rm -Rf /usr/share/ca-certificates/gitlab
    fi
    sudo mkdir /usr/share/ca-certificates/gitlab
    sudo cp $HOST_PROJECTS_FOLDER/$TEMP_FOLDER/jenkins-pipeline-k8s-test/gitlab.local.nip.io.ca.crt /usr/share/ca-certificates/gitlab/gitlab.local.nip.io.ca.crt
    sudo dpkg-reconfigure ca-certificates
    sudo update-ca-certificates
fi

if [[ $INSTALL_JENKINS = "true" ]]
then
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/jenkins-master && docker build -t c3alm-sgt/cloudbees-core-mm-sgt ."
    kubectl create serviceaccount jenkins
    kubectl create -f $HOST_PROJECTS_FOLDER/jenkins-k8s-configuration/pre/sgt-secrets.yaml
    kubectl create -f $HOST_PROJECTS_FOLDER/jenkins-k8s-configuration/pre/sgt-config-map.yaml
    MINIKUBE_IP=$(minikube ip)
    sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/jenkins_yaml.yml > $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/output.file
    kubectl create -f $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/output.file
    rn $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/output.file
fi

if [[ $INSTALL_AGENTS = "true" ]]
then
    JNLP_AGENT_FOLDER=jnlp-agent
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/$JNLP_AGENT_FOLDER/ && docker build -t c3alm-sgt/jnlp-agent ."

    MAVEN_JNLP_AGENT_FOLDER=maven-jnlp-agent
    minikube ssh "cd $MINIKUBE_PROJECTS_FOLDER/$MAVEN_JNLP_AGENT_FOLDER/ && docker build -t c3alm-sgt/maven-jnlp-agent ."
fi

#NODE_PORT=$(kubectl get services jenkins --namespace jenkins -o jsonpath='{.spec.ports[0].nodePort}')
#MINIKUBE_IP=$(minikube ip)

#echo ""
#echo "***************************************"
#echo ""
#echo "Jenkins Url to access: http://$MINIKUBE_IP:$NODE_PORT"
#echo ""
#INTERNAL_IP=$(kubectl get pod --namespace jenkins -o jsonpath='{.items[0].status.podIP}')

#echo "Jenkins Url to configure Kubernetes Plugin: http://$INTERNAL_IP:8080"
#echo ""
#echo "Junkins Tunnel to configure Kubernetes Plugion: http://$INTERNAL_IP:50000"
#echo ""

#cp ${HOME}/.kube/config ./config
#PWD=$(pwd)
#echo "Configure a secret file for kubernetes config file located at: $PWD/config"
#echo ""
#echo "Configure Kubernetes Url: $KUBERNETES_URL"
#echo ""
#echo "***************************************"