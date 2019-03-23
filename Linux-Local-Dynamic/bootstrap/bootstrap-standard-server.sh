#!bin/bash

ssh-keyscan -H wl-l01 >> ~/.ssh/known_hosts

export PATH=/opt/puppetlabs/bin:$PATH

#Setup build.log file in /tmp
touch /tmp/build.log
chmod 755 /tmp/build.log

#Update path to include puppet for azuser
echo "$(date) - Added puppet to path for azuser" >> /tmp/build.log
sudo echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /home/azuser/.bashrc

#Update path to include puppet for root
echo "$(date) - Added puppet to path for root" >> /tmp/build.log
echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> /root/.bashrc

#Download puppet repository for the current version of Ubuntu
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

#Install Puppet agent
echo "$(date) - Running apt-get install -y puppet-agent" >> /tmp/build.log
apt-get install -y puppet-agent

#Moving dummy puppet-agent.conf to /etc/puppetlabs/puppet/puppet.conf
echo "$(date) - Moving puppet-agent.conf to /etc/puppetlabs/puppet/puppet.conf.  Running: 'mv puppet-agent.conf /etc/puppetlabs/puppet/puppet.conf'" >> /tmp/build.log
mv puppet-agent.conf /etc/puppetlabs/puppet/puppet.conf

#Changing ownership of puppet config file
echo "$(date) - Setting root as owner of /etc/puppetlabs/puppet/puppet.conf.  Running: 'chown root:root /etc/puppetlabs/puppet/puppet.conf'" >> /tmp/build.log
chown root:root /etc/puppetlabs/puppet/puppet.conf

#Changing security on /etc/puppetlabs/puppet/puppet.conf to 755
echo "$(date) - Changing security to /etc/puppetlabs/puppet/puppet.conf.  Running: 'chmod 755 /etc/puppetlabs/puppet/puppet.conf'" >> /tmp/build.log
chown root:root /etc/puppetlabs/puppet/puppet.conf
chmod 755 /etc/puppetlabs/puppet/puppet.conf

#Set Puppet Master server for management of local server
echo "$(date) - Setting puppet master to $1 in puppet.conf" >> /tmp/build.log
sed -i "/\[main\]/{:a;n;/\#server = /s/.*/server = $1/;Ta;}" /etc/puppetlabs/puppet/puppet.conf

#Set Puppet agent cert name in puppet.conf
echo "$(date) - Setting cert name for local server to $1 for puppet agent in puppet.conf." >> /tmp/build.log
sed -i "/\[main\]/{:a;n;/\#certname = /s/.*/certname = $2/;Ta;}" /etc/puppetlabs/puppet/puppet.conf

#Set Puppet Master server for management of local server
echo "$(date) - Attempting to pull puppet configuration from master.  Running: '/opt/puppetlabs/bin/puppet agent -t'" >> /tmp/build.log
/opt/puppetlabs/bin/puppet agent -t

#Starting Puppet agent service
echo "$(date) - Starting puppet agent service. Running: 'service puppet start'"
service puppet start

#Move ssh key to azuser .ssh directory
mkdir -p /home/azuser/.ssh && chown azuser:azuser /home/azuser/.ssh && chmod 700 /home/azuser/.ssh && mv id_rsa /home/azuser/.ssh