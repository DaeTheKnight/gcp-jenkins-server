## 1. install java
    type the following:
        sudo apt-get install openjdk-11-jdk

    You may run into an issue where apt-get is not up to date. 
    The error message may say something along the lines of:
        E: Unable to locate package openjdk-11-jdk

    In that case type the following:
        sudo apt-get update

## 2. install jenkins
    Utilize this link to find updated commands:
        https://pkg.jenkins.io/debian/
    
    Here are the commands I found on 9/29/2025:

        This is the Debian package repository of Jenkins to automate installation and upgrade:
            sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
            https://pkg.jenkins.io/debian/jenkins.io-2023.key

        Then add a Jenkins apt repository entry:
              echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

        Update your local package index, then finally install Jenkins:
            sudo apt-get update
            sudo apt-get install fontconfig openjdk-17-jre
            sudo apt-get install jenkins

## 3. check server status
    Use this command to check if the server is running properly:
        sudo systemctl status jenkins

        This will put you in a text menu like vim would. You can press [control + C] to exit this menu
    
## 4. Open jenkins
    Open a new tab on your local web browser and type in your VM's external ip followed by :8080
        This opens that address with the port 8080

## 5. Unlock jenkins
    On the webpage you should be presented with the location of the inital admin password, copy it.
        At this time mine looks like: /var/lib/jenkins/secrets/initialAdminPassword
    
    Then you can utilize the cat command to print out what is at that location on your vm:
        cat /var/lib/jenkins/secrets/initialAdminPassword

        You may need the sudo command for permissions. 
            sudo cat /var/lib/jenkins/secrets/initialAdminPassword

    Copy the password that has printed in your vm and use it to login

## 6. Customize jenkins
    Congrats!!! You've installed Jenkins.