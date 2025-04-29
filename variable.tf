variable "unique_prefix" {
  description = "Name that will be used as prefix for all the resources deployed"
}

provider "aws" {
    #profile = "default"
    region  = var.region
}

variable "region" {
    description = "region that you will be deploying your resources"
}

data "aws_availability_zones" "azs" {
}

variable "main_vpc_cidr" {
  description = "Main VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "log4j_user_data"{
    default = <<-BOOTSTRAP
#!/bin/bash
echo "Executing Bootstrap Script..." >> /var/log/aws-gameday-cloud-init.log
sudo apt update -y && apt upgrade -y >> /var/log/aws-gameday-cloud-init.log
sudo apt install -y openjdk-11-jdk wget unzip >> /var/log/aws-gameday-cloud-init.log
cd /tmp
sudo wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.73/bin/apache-tomcat-8.5.73.tar.gz >> /var/log/aws-gameday-cloud-init.log
sudo tar -xzf apache-tomcat-8.5.73.tar.gz
sudo mv apache-tomcat-8.5.73 /opt/tomcat
sudo wget https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.14.1/log4j-core-2.14.1.jar -P /opt/tomcat/lib/ >> /var/log/aws-gameday-cloud-init.log
sudo wget https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.14.1/log4j-api-2.14.1.jar -P /opt/tomcat/lib/ >> /var/log/aws-gameday-cloud-init.log
echo "Writing to war file..." >> /var/log/aws-gameday-cloud-init.log
sudo cat <<EOF > /opt/tomcat/webapps/vulnerable-log4j-app.war
<!DOCTYPE html>
<html>
<body>
<h1>Gameday App</h1>
<form action="/log4j" method="post">
    Enter data: <input type="text" name="data">
    <button type="submit">Submit</button>
</form>
</body>
</html>
EOF

echo "Executing tomcat startup script..." >> /var/log/aws-gameday-cloud-init.log
sudo chmod +x /opt/tomcat/bin/*.sh
sudo /opt/tomcat/bin/startup.sh

echo "Writing to tomcat service file..." >> /var/log/aws-gameday-cloud-init.log
sudo cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=forking
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

echo "Updating and restarting daemon-reload and tomcat services" >> /var/log/aws-gameday-cloud-init.log
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat
echo "Bootstrap completed" >> /var/log/aws-gameday-cloud-init.log
BOOTSTRAP

}

