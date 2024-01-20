#!/bin/bash
rm -rf /usr/share/tomcat9/webapps/ccdemo*
rm -rf usr/local/tomcat9/webapps/ROOT/ccdemo*



#!/bin/bash
yum update -y
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-11-amazon-corretto-devel
wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.84/bin/apache-tomcat-9.0.84.tar.gz
tar xzf apache-tomcat-9.0.84.tar.gz
mv apache-tomcat-9.0.84 /usr/local/tomcat9
echo "<!DOCTYPE html>
<html>
<body>

<h1>Welcome to My Website!</h1>
<p>This is a paragraph.</p>

</body>
</html>" > index.html
mv index.html /usr/local/tomcat9/webapps/ROOT/

# Create a new tomcat user and group
groupadd tomcat
useradd -s /bin/false -g tomcat -d /usr/local/tomcat9 tomcat

# Change the owner of the Tomcat directory to the tomcat user and group
chown -R tomcat: /usr/local/tomcat9

# Give the tomcat user read and execute permissions for the entire Tomcat directory
chmod -R 755 /usr/local/tomcat9

# Create a systemd service file for Tomcat
echo "[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto
Environment=CATALINA_PID=/usr/local/tomcat9/temp/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat9
Environment=CATALINA_BASE=/usr/local/tomcat9
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/usr/local/tomcat9/bin/startup.sh
ExecStop=/usr/local/tomcat9/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/tomcat.service

# Reload systemd to apply the new service file
systemctl daemon-reload

# Start Tomcat
systemctl start tomcat

# Enable Tomcat to start on boot
systemctl enable tomcat

#Code Deploy
yum install -y ruby wget
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto
service codedeploy-agent start