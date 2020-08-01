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

sudo passwd root
sudo apt update
sudo apt install ansible
sudo nano /etc/ansible/hosts
127.0.0.1 ansible_connection=local
ansible-playbook gitlab/ansible.yml  --become