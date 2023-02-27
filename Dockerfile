FROM jenkins/jenkins
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
RUN jenkins-plugin-cli --plugins -f /usr/share/jenkins/ref/plugins.txt