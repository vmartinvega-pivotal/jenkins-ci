HOST_PROJECTS_FOLDER=/home/vicente/Projects

kubectl delete service jenkins
kubectl delete service jenkins-tcp-port
kubectl delete service jenkins-jnlp-port
kubectl delete deploy jenkins
kubectl delete ingress jenkins-ingress
kubectl delete secret jenkins-secrets

kubectl create -f $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/jenkins-deployment.yaml

$HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/kubernetes/wait-until-pods-ready.sh 60 5

INTERNAL_IP=$(kubectl get pod -o jsonpath='{.items[0].status.podIP}')
KUBECONFIG_FILE_BYTES=$(cat ${HOME}/.kube/config | base64 --wrap=0)
sed "s/JENKINS_URL/http:\/\/$INTERNAL_IP:8080/g" $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/jenkins-conf-template.yaml > $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/output.file
sed "s/JENKINS_TUNNEL/http:\/\/$INTERNAL_IP:50000/g" $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/output.file > $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/output1.file
sed "s/KUBERNETES_URL/https:\/\/$MINIKUBE_IP:8443/g" $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/output1.file > $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/output2.file
sed "s/KUBECONFIG_FILE_BYTES/$KUBECONFIG_FILE_BYTES/g" $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/output2.file > $HOST_PROJECTS_FOLDER/jenkins-pipeline-k8s-test/jenkins/jenkins-conf.yaml