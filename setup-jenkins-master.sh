#!/bin/bash

echo "Updating Redhat linux Enterprise"

sudo yum update -y

echo "Install SSM Agent for Redhat Linux"

sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
# sudo systemctl status amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

echo " Net tools"
sudo yum install -y net-tools

echo " Install git & efs-utils"
sudo yum -y install git
git clone https://github.com/aws/efs-utils
cd ./efs-utils/
sudo yum -y install make
sudo yum -y install rpm-build
make rpm
sudo yum -y install ./build/amazon-efs-utils*rpm
sudo yum -y install wget

if [[ "$(python3 -V 2>&1)" =~ ^(Python 3.6.*) ]]; then
    sudo wget https://bootstrap.pypa.io/pip/3.6/get-pip.py -O /tmp/get-pip.py
elif [[ "$(python3 -V 2>&1)" =~ ^(Python 3.5.*) ]]; then
    sudo wget https://bootstrap.pypa.io/pip/3.5/get-pip.py -O /tmp/get-pip.py
elif [[ "$(python3 -V 2>&1)" =~ ^(Python 3.4.*) ]]; then
    sudo wget https://bootstrap.pypa.io/pip/3.4/get-pip.py -O /tmp/get-pip.py
else
    sudo wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
fi

python3 /tmp/get-pip.py
pip3 install botocore
/usr/local/bin/pip3 install botocore
/usr/local/bin/pip3 install botocore --upgrade


echo "Install Jenkins LTS release"

sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
# Add required dependencies for the jenkins package
sudo yum install fontconfig java-17-openjdk -y
sudo yum install jenkins -y
sudo sed -i 's/^#Environment="JENKINS_LOG=%L\/jenkins\/jenkins\.log"/Environment="JENKINS_LOG=%L\/jenkins\/jenkins\.log"/' /usr/lib/systemd/system/jenkins.service
sudo sed -i 's/^After=network.target/After=network.target efs-mount.service/' /usr/lib/systemd/system/jenkins.service
sudo systemctl daemon-reload

echo " Mount EFS file system"
mkdir -p /mnt/efs
echo "fs-0fbb24a2504906949.efs.eu-central-1.amazonaws.com:/  /mnt/efs  nfs4  defaults,_netdev 0  0" >> /etc/fstab
mount -a
sleep 15
mkdir -p /mnt/efs/jenkins
mkdir -p /mnt/efs/jenkins-log
chown -R jenkins:jenkins /mnt/efs/jenkins
chown -R jenkins:jenkins /mnt/efs/jenkins-log
rm -rf /var/lib/jenkins
ln -s /mnt/efs/jenkins /var/lib/jenkins
ln -s /mnt/efs/jenkins-log /var/log/jenkins
chown -R jenkins:jenkins /var/lib/jenkins 
chown -R jenkins:jenkins /var/log/jenkins

echo "configure Jenkins"
mkdir -p /var/lib/jenkins/init.groovy.d
mv /tmp/scripts/*.groovy /var/lib/jenkins/init.groovy.d/
sudo mv /tmp/scripts/jenkins  /etc/logrotate.d/
chown root:root /etc/logrotate.d/jenkins
chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d
sudo systemctl enable jenkins
sudo systemctl start jenkins
sleep 150
cat << EOF > /usr/lib/systemd/system/efs-mount.service
[Unit]
Description=Mount EFS File System
Requires=network-online.target
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/mount -t nfs4 -o defaults,_netdev fs-0fbb24a2504906949.efs.eu-central-1.amazonaws.com:/ /mnt/efs

[Install]
WantedBy=multi-user.target
EOF
chown root:root /usr/lib/systemd/system/efs-mount.service
chmod 644 /usr/lib/systemd/system/efs-mount.service
sudo systemctl daemon-reload
sudo systemctl enable efs-mount.service
echo " Packer configuration completed successfully"