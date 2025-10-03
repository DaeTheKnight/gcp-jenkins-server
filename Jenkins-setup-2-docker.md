# 1. Install docker

    Check this link for docker installation instructions:
        https://docs.docker.com/engine/install/ubuntu/

## Remove any conflicting bloatware that comes with ubuntu, use this command:
        for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

        that command removes the following: docker.io, docker-compose, docker-compose-v2, docker-doc, podman-docker.
        But apt-get might report that you have none of these packages installed even though you do.

## Setup the apt repository

        Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker apt repository. Afterward, you can install and update Docker from the repository.

Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

Add the repository to Apt sources:

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

## Install the Docker packages.

Use this command to install and run Docker:

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## Verify that Docker is running

The Docker service usually starts automatically after installation. 
To verify that Docker is running, use:

    sudo systemctl status docker

## Troubleshoot startup

If its not running then start it. Some systems may have this behavior disabled and will require a manual start:

    sudo systemctl start docker

You can verify that the installation is successful by running the hello-world image:

    sudo docker run hello-world


# 2. Install Jenkins

    Before you can install jenkins you must configure the environment
    Use these commands:

        sudo systemctl disable firewalld

        sudo systemctl enable --now docker

        sudo usermod -aG docker ubuntu

        sudo chmod 666 /var/run/docker.sock



    To install Jenkins use the following command:

        docker run -d -p 8080:8080 -p 50000:50000 -v /root/jenkins_home:/var/jenkins_home -u root --name jenkins-ubuntu-1 --privileged=true -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts

            the part where it says "docker run" is used to create a new container from an image and start it
            the part where it says "-d" is used to put it in detached mode (make it run in the background instead of occupying your terminal)
            the part where it says "-p" selects the port
            8080 is the port. the first one is for the host machine, the second for the docker port
            the second "-p" is to open a port for slave communication
            the part where it says "-v" is to mount/bind
            the part where it says "/root/jenkins_home:/var/jenkins_home" is the mount location for th configuration
            the part where it says "-u" is the user flag
            root is the user
            the part where it says "--name" is the container name flag
            the part where it says "jenkins-ubuntu-1" is the container name (it will give an error if this name is already in use)
            and "jenkins/jenkins:lts" is the image

    Check on the container status with this command:

        docker ps

    Look at Jenkins installation files in the directory:

        sudo ls -al /root /root/jenkins_home

# 3. Install Plugins

## Open Jenkins

        Use the external ip address of your vm with the port :8080 at the end in your browser

            136.113.3.2:8080

## Initial login to Jenkins

        The install was done in root not var so use the following command:

            sudo cat /root/jenkins_home/secrets/initialAdminPassword
        
        Login and setup user credentials

## Install plugin

    In order to properly control containers & where code is executed you need plugins.

    Navigate the jenkins gui to find:

        Manage Jenkins > Plugins > Search for: Docker > Click on Docker

    You must restart your Jenkins server after installing the plugins for it to work.
    In the VM use the command:

        docker restart jenkins-ubuntu-1

    Afterwards refresh your jenkins page
    If you click on "manage jenkins" you will see a new option called "clouds"

# 4. Create Cloud/Agent

    Click on clouds
    Click on New Cloud
    Check the Docker type button
    Click create
    Name it

    Click on Docker Cloud details
    Where it asks for the Docker Host URL there is a question mark button 
    that supplies the needed URL for UNIX systems like ubuntu
    
    Copy and paste that URL
    
        unix:///var/run/docker.sock

    Click test connection

# 5. Configure Jenkins

    After testing the connection & seeing that the connection is live there is a check box that you should click.
    It should be right beneath the Version & API Version displayed when the connection is live

    Docker Agent Template

        Add Docker template
        Lable the template (agent-1)
        Click enable
        Name the template (agent-a)
        Select the docker image jenkins/jenkins:lts
        choose instance capacity (this is the max allowed)
        Under the connect method section 
            select attach docker container
            enter root as user
        Save
        
    Cloud Statistics

        You can check here to see whatever has been launched on that particular cloud 

# 6. Utilize Jenkins

    Now you can create a job for use with Docker
    In your job's configure tab you'll see a new option labled "restrict where this project can be run"
        Using this will allow you to bind a specific job to a specific agent

            Type in the lable of the agent you created (agent-1)
            Click save

# 7. Troubleshooting

    You can check the logs if there is an error using this command in the VM:

        docker logs jenkins-ubuntu-1

    Status of Docker command:

        docker ps

    If the container needs to be removed (forcefully) use this command:

        docker rm -f jenkins-ubuntu-1

    To list out all containers 
    You’ll see running, exited (stopped), created, and restarting containers
    Use this command:

        docker ps -a

    Check Cloud Statistics in Jenkins to see the status of a build that is expected to run