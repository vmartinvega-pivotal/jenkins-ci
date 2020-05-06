MINIKUBE_CLIENT_CERTIFICATE=$(kubectl config view -o jsonpath='{.users[?(@.name == "minikube")].user.client-certificate}')
MINIKUBE_CLIENT_KEY=$(kubectl config view -o jsonpath='{.users[?(@.name == "minikube")].user.client-key}')
CA_CERTIFICATE=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "minikube")].cluster.certificate-authority}')
KUBERNETES_URL=$(kubectl config view -o jsonpath='{.clusters[?(@.name == "minikube")].cluster.server}')

kubectl config set-credentials minikube --client-certificate=$MINIKUBE_CLIENT_CERTIFICATE --embed-certs=true
kubectl config set-credentials minikube --client-key=$MINIKUBE_CLIENT_KEY  --embed-certs=true
kubectl config set-cluster minikube --certificate-authority=$CA_CERTIFICATE --embed-certs=true

minikube ssh 'git clone https://github.com/vmartinvega-pivotal/jenkins-pipeline-k8s-test'
minikube ssh 'cd jenkins-pipeline-k8s-test/jenkins && docker build -t vicente/jenkins-image:1.0 .'
minikube ssh 'cd jenkins-pipeline-k8s-test/jenkins && unzip jnlp-agent.zip && docker build -f ./jnlp-agent/Dockerfile -t c3alm-sgt/jnlp-agent .'
minikube ssh 'cd jenkins-pipeline-k8s-test/jenkins && unzip maven-jnlp-agent.zip && docker build -f ./maven-jnlp-agent/Dockerfile -t c3alm-sgt/maven-jnlp-agent .'

kubectl create namespace jenkins
kubectl create -f jenkins/jenkins-deployment.yaml --namespace jenkins
kubectl create -f jenkins/jenkins-service.yaml --namespace jenkins

NODE_PORT=$(kubectl get services jenkins --namespace jenkins -o jsonpath='{.spec.ports[0].nodePort}')
MINIKUBE_IP=$(minikube ip)

echo ""
echo "***************************************"
echo ""
echo "Jenkins Url to access: http://$MINIKUBE_IP:$NODE_PORT"
echo ""
INTERNAL_IP=$(kubectl get pod --namespace jenkins -o jsonpath='{.items[0].status.podIP}')

echo "Jenkins Url to configure Kubernetes Plugin: http://$INTERNAL_IP:8080"
echo ""
echo "Junkins Tunnel to configure Kubernetes Plugion: http://$INTERNAL_IP:50000"
echo ""

cp ${HOME}/.kube/config ./config
PWD=$(pwd)
echo "Configure a secret file for kubernetes config file located at: $PWD/config"
echo ""
echo "Configure Kubernetes Url: $KUBERNETES_URL"
echo ""
echo "***************************************"
