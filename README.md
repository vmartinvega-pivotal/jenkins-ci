# Quick Install

* Install ansible
```
sudo passwd root
sudo apt update
sudo apt install ansible
sudo nano /etc/ansible/hosts
127.0.0.1 ansible_connection=local
git clone https://github.com/vmartinvega-pivotal/jenkins-ci
ansible-galaxy install geerlingguy.gitlab
ansible-galaxy install geerlingguy.docke
ansible-galaxy install gantsign.visual-studio-code
ansible-galaxy install pixelart.chrome
git clone https://github.com/githubixx/ansible-role-kubectl /home/vicente/.ansible/roles/githubixx.kubectl
ansible-playbook ansible/playbook.yml  --become
```

* Install minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
```

* Install Jenkins and agents
```
./install.sh
```