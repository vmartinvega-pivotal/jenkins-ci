# Quick Install


* Install minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```

* Install helm
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh
```

* Install virtuabox
```
sudo apt-get install virtualbox
```

* Install keepass2
```
sudo apt-add-repository ppa:jtaylor/keepass
sudo apt-get update
sudo apt-get install keepass2
```

* Install ansible
```
sudo passwd root
sudo apt update
sudo apt install ansible
```

* Update unsible hosts
```
sudo nano /etc/ansible/hosts
127.0.0.1 ansible_connection=local
```

* Install git
```
sudo apt-get install git
```

* Clone repo
```
mkdir /home/vicente/Projects
cd /home/vicente/Projects
git clone https://github.com/vmartinvega-pivotal/jenkins-ci
```

* Install ansible roles
```
ansible-galaxy install geerlingguy.gitlab
ansible-galaxy install geerlingguy.docker
ansible-galaxy install gantsign.visual-studio-code
ansible-galaxy install pixelart.chrome
ansible-galaxy install geerlingguy.kubernetes
ansible-galaxy install geerlingguy.rabbitmq
ansible-galaxy install geerlingguy.elasticsearch
ansible-galaxy install geerlingguy.kibana
git clone https://github.com/githubixx/ansible-role-kubectl /home/vicente/.ansible/roles/githubixx.kubectl
```
transport.host: localhost
transport.tcp.port: 9300

* Execute playbook
```
ansible-playbook ansible/playbook.yml  --become --extra-vars "ansible_sudo_pass=yourPassword"
```

* Install Jenkins, gitlab and agents
```
./install.sh
```
