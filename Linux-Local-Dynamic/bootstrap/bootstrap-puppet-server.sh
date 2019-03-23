#!/bin/bash

#Add the jumbpbox server to known_hosts
ssh-keyscan -H jb-l01 >> ~/.ssh/known_hosts

#Update our path
export PATH=/opt/puppetlabs/bin:$PATH

#Setup build.log file in /tmp
touch /tmp/build.log

#Update path to include puppet for azuser
echo "$(date) - Added puppet to path for azuser" >> /tmp/build.log
echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /home/azuser/.bashrc

#Update path to include puppet for root
echo "$(date) - Added puppet to path for root" >> /tmp/build.log
echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /root/.bashrc
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
#Download puppet repository for the current version of Ubuntub
echo "$(date) - Downloading puppet repository for apt.  Running: 'wget https://apt.puppetlabs.com/puppet6-release-$(lsb_release -sc).deb'" >> /tmp/build.log
wget https://apt.puppetlabs.com/puppet6-release-$(lsb_release -sc).deb

#Install puppet repository for the current version of Ubuntu
echo "$(date) - Installing puppet repository for apt.  Running: 'dpkg -i puppet6-release-$(lsb_release -sc).deb'" >> /tmp/build.log
dpkg -i puppet6-release-$(lsb_release -sc).deb
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
#Add the Universe repository for the current version of Ubuntu
echo "$(date) - Adding Universe repository for apt.  Running: 'add-apt-repository \"deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe\"'" >> /tmp/build.log
add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"

#Update Apt
echo "$(date) - Running apt-get update -y" >> /tmp/build.log
apt-get update -y

#Install Puppet server package
echo "$(date) - Installing Puppet Master. Running: 'apt-get install -y puppetserver'" >> /tmp/build.log
apt-get install -y puppetserver

#Copy dummy puppet.conf to /etc/puppetlabs/puppet/
mv puppet-master.conf /etc/puppetlabs/puppet/puppet.conf
chown root:root /etc/puppetlabs/puppet/puppet.conf

#Set Puppet Master server for management of local server
echo "$(date) - Setting puppet master server name to $1 for puppet master" >> /tmp/build.log
sed -i "/\[main\]/{:a;n;/\#server = /s/.*/server = $1/;Ta;}" /etc/puppetlabs/puppet/puppet.conf

#Set Puppet agent cert name in puppet.conf
echo "$(date) - Setting cert name to $1 for puppet master." >> /tmp/build.log
sed -i "/\[main\]/{:a;n;/\#certname = /s/.*/certname = $1/;Ta;}" /etc/puppetlabs/puppet/puppet.conf

#Set Puppet Master cert name in puppet.conf
echo "$(date) - Setting cert name to $1 for puppet master." >> /tmp/build.log
sed -i "/\[master\]/{:a;n;/\#certname = /s/.*/certname = $1/;Ta;}" /etc/puppetlabs/puppet/puppet.conf

#IMPORTANT!!!!!!!! This command auto-signs all certificates.  It's only used because this is a test environment.  If using this in production, CHANGE THE COMMAND!!
echo "$(date) - Turning on autosign for all CA requests." >> /tmp/build.log
touch /etc/puppetlabs/puppet/autosign.conf && echo "*" >> /etc/puppetlabs/puppet/autosign.conf

#Setting up Puppet CA
echo "$(date) - Setting up CA on Puppet Master. Running: '/opt/puppetlabs/bin/puppetserver ca setup'" >> /tmp/build.log
/opt/puppetlabs/bin/puppetserver ca setup

#Copy site.pp to production manifests directory
echo "$(date) - Copying site manifest to production manifests directory. Running: 'cp site.pp /etc/puppetlabs/code/environments/production/manifests'" >> /tmp/build.log
mv site.pp /etc/puppetlabs/code/environments/production/manifests

#Start the Puppet server
echo "$(date) - Starting puppet master. Running: 'systemctl start puppetserver'" >> /tmp/build.log
systemctl start puppetserver

#Install Puppet agent
echo "$(date) - Installing puppet agent. Running: 'apt-get install -y puppet-agent'" >> /tmp/build.log
apt-get install -y puppet-agent

#Install puppet modules
echo "$(date) - Installing puppet modules.'" >> /tmp/build.log
puppet module install puppetlabs-ntp
puppet module install puppetlabs-firewall

#Configure the local agent
echo "$(date) - Attempting to gather puppet config. Running: '/opt/puppetlabs/bin/puppet agent -t'" >> /tmp/build.log
/opt/puppetlabs/bin/puppet agent -t

#Starting Puppet agent service
echo "$(date) - Starting puppet agent service. Running: 'service puppet start'"
service puppet start

#ssh-keyscan -H 192.168.1.162 >> ~/.ssh/known_hosts

#bolt task run --nodes aut-l01 -u azuser --run-as root puppet_conf action=get setting=certname

#bolt task run --nodes aut-l01 -u azuser --run-as root package action=install name=postgresql