sudo gitlab-ctl uninstall
sudo gitlab-ctl cleanse
sudo gitlab-ctl remove-accounts
sudo dpkg -P gitlab-ce
sudo rm -Rf /opt/gitlab
sudo rm -Rf /var/opt/gitlab
sudo rm -Rf /etc/gitlab 
sudo rm -Rf /var/log/gitlab