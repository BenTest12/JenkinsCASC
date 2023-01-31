# Jenkins - CASC Using Docker Compose
![Alt text](https://raw.githubusercontent.com/jenkins-infra/plugins-wiki-docs/master/docker-compose-build-step/docs/images/docker-compose-jenkins.jpg "")

# Introduction
**Jenkins: Configuration As Code** is a feature in jenkins which enables us to pre-define a testing area for specific testing purposes.

This project is an example of a case where we either build a testing area for a specific department in an organization , or if we decide to offer this configuration as a solution to a company.

## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)

## General info
**The Jenkins Configuration as Code (JCasC)** feature defines Jenkins configuration parameters in a human-readable YAML file that can be stored as source code. This essentially captures the configuration parameters and values that are used when configuring Jenkins from the web UI. The configuration can then be modified by editing this file and then applying it.

JCasC provides the convenience and flexibility of configuring controllers without using the UI. It does not require more understanding of the configuration parameters than is required to configure Jenkins through the UI and it provides some checks on the values that are provided.
The JCasC configuration file can be checked into an SCM, which enables you to determine who made what modifications to the configuration and to roll back to a previous configuration if necessary.

## Technologies
This Project was created with:
* [VMWARE Workstation PRO](https://www.vmware.com/il/products/workstation-pro.html) - version 17
* [Ubuntu Server](https://ubuntu.com/download/server) - version: 22.04.1
* [Docker-CE On Ubuntu Server](https://docs.docker.com/engine/install/ubuntu/) version: 20.10.23
* [Jenkins Community Docker Container Image](https://hub.docker.com/r/jenkins/jenkins) - Latest version was used (31.01.2023)

## Setup

After Setting up a **Virtual Machine** and installing **Ubuntu Server** we proceed to installing **Docker-CE** from the following [Link](https://docs.docker.com/engine/install/ubuntu/).

Afterwards , we verify our configuration.

```bash
ben@test:~$ docker -v
Docker version 20.10.23, build 7155243
```

Create a directory in your location of choice , i used my ```home``` directory.
```bash
ben@test:~$ cd ~
ben@test:~$
ben@test:~$ mkdir JenkinsCASC
ben@test:~$ cd JenkinsCASC/
```
* Cloning the repository files and executing them.
```bash
ben@test:~/JenkinsCASC$ git clone https://github.com/BenTest12/JenkinsCASC.git
Cloning into 'JenkinsCASC'...
remote: Enumerating objects: 13, done.
remote: Counting objects: 100% (13/13), done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 13 (delta 0), reused 7 (delta 0), pack-reused 0
Receiving objects: 100% (13/13), 6.09 KiB | 2.03 MiB/s, done.
ben@test:~/JenkinsCASC$ ll
total 12
drwxrwxr-x  3 ben ben 4096 Jan 31 09:05 ./
drwxr-x--- 10 ben ben 4096 Jan 31 09:03 ../
drwxrwxr-x  3 ben ben 4096 Jan 31 09:05 JenkinsCASC/
ben@test:~/JenkinsCASC$  
```
* Navigate to the cloned repository dir.
```bash
ben@test:~/JenkinsCASC$ cd JenkinsCASC/
ben@test:~/JenkinsCASC/JenkinsCASC$ ll
total 44
drwxrwxr-x 3 ben ben 4096 Jan 31 09:05 ./
drwxrwxr-x 3 ben ben 4096 Jan 31 09:05 ../
-rw-rw-r-- 1 ben ben  512 Jan 31 09:05 casc.yaml
-rw-rw-r-- 1 ben ben  224 Jan 31 09:05 docker-compose.yml
-rw-rw-r-- 1 ben ben  292 Jan 31 09:05 Dockerfile
drwxrwxr-x 8 ben ben 4096 Jan 31 09:05 .git/
-rw-rw-r-- 1 ben ben 6942 Jan 31 09:05 .gitignore
-rw-rw-r-- 1 ben ben 1496 Jan 31 09:05 LICENSE.md
-rw-rw-r-- 1 ben ben  132 Jan 31 09:05 plugins.txt
-rw-rw-r-- 1 ben ben   13 Jan 31 09:05 README.md
ben@test:~/JenkinsCASC/JenkinsCASC$ 
```

# Dockerfile
The ```Dockerfile``` Consists of the following configurations.
```go
FROM jenkins/jenkins
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
RUN jenkins-plugin-cli --plugins -f /usr/share/jenkins/ref/plugins.txt
```

This setting tells the jenkins container to **skip** the initial setup and create the service without users.
```go
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
```

This setting **Defines** our pre-configured **Configuration As A Code** settings to the jenkins service container.
```go
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
```

These settings copy our configuration to the container , to the designated directory.
```go
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
```

And finally , This setting builds our **CASC** environment with the plugins mentioned in the ```plugins.txt``` file.
```go
RUN jenkins-plugin-cli --plugins -f /usr/share/jenkins/ref/plugins.txt
```

# plugins.txt
The ```plugins.txt``` file allows us to install predefined plugins into our **CASC** solution.
* Note that configuration-as-code is mentioned in the file , this is because in order to use jenkins CASC we must install the CASC plugin first.

```txt
job-dsl 
git 
authorize-project
matrix-auth
github-branch-source 
pipeline-utility-steps 
credentials-binding 
configuration-as-code
```

# secrets.env
This file is used to store sensitive credentials which are used during the configuration process.

To define a custom user and password , create the ```secrets.env``` file and enter the following lines.
```go
JENKINS_ADMIN_ID=
JENKINS_ADMIN_PASSWORD=
```
Where the ```JENKINS_ADMIN_ID``` represents the user we wish to define , and the ```JENKINS_ADMIN_PASSWORD``` is the preconfigured users password.

# casc.yml
The ```casc.yaml``` file is the service configuration that the **jenkins** service will follow when booting up and building our environment.

The ```casc.yaml``` file consists of the following settings.
```yaml
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
       - id: ${JENKINS_ADMIN_ID}
         password: ${JENKINS_ADMIN_PASSWORD}
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
  remotingSecurity:
    enabled: true
security:
  queueItemAuthenticator:
    authenticators:
    - global:
        strategy: triggeringUsersAuthorizationStrategy
unclassified:
  location:
    url: http://localhost:8080/
```

* The ```allowSignup``` flag is marked with the **false** flag , to disallow anonymous users to sign up to the service.

* The ```users``` flag creates a **Predefined User And Password** which are referenced from a ```secrets.env``` file , This allows us to create this service as a global template.

* The ```permissions``` flag defines that **Only Authenticated Users** can use the jenkins service.

* The ```queueItemAuthenticator``` setting defines that if a jenkins worker from another environment runs , that worker will have no access to other pipelines and their resources, only to its designated pipeline.

# docker-compose.yaml
If we examine the docker compose file , we will notice that a custom image was used - ```jenkins:jcasc```.

```yaml
services:
  jenkins:
    image: jenkins:jcasc
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      
    env_file: secrets.env
volumes:
  jenkins_home:

```
In the [Technologies](#technologies) section it was mentioned that the official community jenkins image was used , however we must build our own image in order to create our own custom **Configuration As A Code (CASC)** Solution.
The cloned repository directory contains a ```Dockerfile``` , proceed building the image by using the following command (**Make sure you are in the same directory as the ```Dockerfile``` Itself.**)
```bash
ben@test:~/JenkinsCASC/JenkinsCASC$ pwd
/home/ben/JenkinsCASC/JenkinsCASC
ben@test:~/JenkinsCASC/JenkinsCASC$ ll
total 44
drwxrwxr-x 3 ben ben 4096 Jan 31 09:05 ./
drwxrwxr-x 3 ben ben 4096 Jan 31 09:05 ../
-rw-rw-r-- 1 ben ben  512 Jan 31 09:05 casc.yaml
-rw-rw-r-- 1 ben ben  224 Jan 31 09:05 docker-compose.yml
-rw-rw-r-- 1 ben ben  292 Jan 31 09:05 Dockerfile
drwxrwxr-x 8 ben ben 4096 Jan 31 09:05 .git/
-rw-rw-r-- 1 ben ben 6942 Jan 31 09:05 .gitignore
-rw-rw-r-- 1 ben ben 1496 Jan 31 09:05 LICENSE.md
-rw-rw-r-- 1 ben ben  132 Jan 31 09:05 plugins.txt
-rw-rw-r-- 1 ben ben   13 Jan 31 09:05 README.md
ben@test:~/JenkinsCASC/JenkinsCASC$ docker build -t jenkins:jcasc .
Sending build context to Docker daemon  78.85kB
Step 1/6 : FROM jenkins/jenkins
 ---> f48b4a359c49
Step 2/6 : ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
 ---> Using cache
 ---> 65d6e108d565
Step 3/6 : ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
 ---> Using cache
 ---> c9045a42cdb1
Step 4/6 : COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
 ---> Using cache
 ---> ab91d36eb069
Step 5/6 : COPY casc.yaml /var/jenkins_home/casc.yaml
 ---> Using cache
 ---> d095879953df
Step 6/6 : RUN jenkins-plugin-cli --plugins -f /usr/share/jenkins/ref/plugins.txt
 ---> Using cache
 ---> 6a24c7b751ef
Successfully built 6a24c7b751ef
Successfully tagged jenkins:jcasc
```

Finally , after pre configuring our environment we may proceed to executing the service.
```bash
ben@test:~/test/Jenkins/Final/JenkinsCASC$ docker compose up
[+] Running 3/3
 ⠿ Network jenkinscasc_default        Created                                                                                   0.1s
 ⠿ Volume "jenkinscasc_jenkins_home"  Created                                                                                   0.0s
 ⠿ Container jenkinscasc-jenkins-1    Created                                                                                   0.1s
Attaching to jenkinscasc-jenkins-1
jenkinscasc-jenkins-1  | Running from: /usr/share/jenkins/jenkins.war
jenkinscasc-jenkins-1  | webroot: /var/jenkins_home/war
jenkinscasc-jenkins-1  | 2023-01-31 09:43:17.283+0000 [id=1]    INFO    winstone.Logger#logInternal: Beginning extraction from war file
jenkinscasc-jenkins-1  | 2023-01-31 09:43:19.939+0000 [id=1]    WARNING o.e.j.s.handle
```
The service should proceed to execute , finally the webservice is available at - [http://localhost:8080/](http://localhost:8080/)
![Alt text](https://i.ibb.co/CJqjwXN/login.png)
![Alt text](https://i.ibb.co/wK37YrD/dashboard.png)

## License

[BSD3](https://github.com/teamdigitale/licenses/blob/master/BSD-3-Clause)