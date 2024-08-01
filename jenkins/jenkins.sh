#!/bin/bash

# Download the Jenkins key and add the Jenkins repository
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists and install Jenkins
sudo apt-get update -y
sudo apt-get install jenkins -y

# Install Java and required packages
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y

# Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Download and install OpenJDK 13
sudo wget https://download.java.net/java/GA/jdk13.0.1/cec27d702aa74d5a8630c65ae61e4305/9/GPL/openjdk-13.0.1_linux-x64_bin.tar.gz
sudo tar -xvf openjdk-13.0.1_linux-x64_bin.tar.gz
sudo mv jdk-13.0.1 /opt/

# Download and install Apache Maven
/* sudo wget https://dlcdn.apache.org/maven/maven-3/3.9.8/binaries/apache-maven-3.9.8-bin.tar.gz
/* sudo tar -xvf apache-maven-3.9.8-bin.tar.gz
/* sudo mv apache-maven-3.9.8 /opt/

# Configure environment variables for the current session
/* export JAVA_HOME='/opt/jdk-13.0.1'
/* export M2_HOME='/opt/apache-maven-3.9.8'
/* export PATH="$JAVA_HOME/bin:$M2_HOME/bin:$PATH"

# Make the environment variables persistent across sessions
/* echo "export JAVA_HOME='/opt/jdk-13.0.1'" | sudo tee -a /etc/profile.d/maven.sh
/* echo "export M2_HOME='/opt/apache-maven-3.9.8'" | sudo tee -a /etc/profile.d/maven.sh
/* echo "export PATH=\"$JAVA_HOME/bin:$M2_HOME/bin:\$PATH\"" | sudo tee -a /etc/profile.d/maven.sh

# Reload the profile to apply the new environment variables
/* source /etc/profile.d/maven.sh

# Verify Maven installation
/* mvn --version

# Display initial Jenkins admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
