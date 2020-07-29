# Quick Install

* Install minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```
* Install kubectl
```
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```
* Start minikube
```
minikube start --driver=virtualbox --memory=16g --cpus=8 --disk-size=30g
```

* Clone repo
```
git clone https://github.com/vmartinvega-pivotal/jenkins-pipeline-k8s-test
```

* Install Jenkins and agents
```
./install.sh
```

configure the config file (to connect to kubernetes) to emmbed the certificates
Configure cloud in jenkins
Configure secret from file (the previously created file)
Jenkins url (internal ip for the pod) and port 8080
Jenkins tunnel (internal ip for the pod) and port 50000
Test connectivity

Create pipeline from source control


Copy Dockerfile to minikube to build the jenkins image
```
docker build -t vicente/jenkins-image:1.0 .
```

Create the jenkins deployment
```
kubectl create -f jenkis-deployment.yaml
```

Create the jenkins service
```
kubectl create -f jenkins-service.yaml
```

Configure jenkins web to be displayed in english
```
Jenkins -> Configure -> Locale (en_EN)
```

Configure cloud

