#!/bin/sh
echo "This script will build the ant project"
apt-get -y update
apt-get -y install apt-utils curl dos2unix maven

# install node
curl -sL https://deb.nodesource.com/setup_10.x | bash
apt-get install -y nodejs
curl -L https://npmjs.org/install.sh | sudo sh
# add tomcat, important set CATALINA_HOME for web application dependencies
curl -L https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.94/bin/apache-tomcat-7.0.94.tar.gz --output /tmp/apache-tomcat-7.0.94.tar.gz
tar -C /tmp -xvf /tmp/apache-tomcat-7.0.94.tar.gz
export CATALINA_HOME=/tmp/apache-tomcat-7.0.94

mvn dependency:get -DremoteRepositories=https://repo.k8s.vroc.ai/repository/maven-vroc -DgroupId=ai.vroc -DartifactId=dnp34j -Dversion=0.0.2-SNAPSHOT -Dtransitive=false -Ddest=./WebContent/WEB-INF/lib/dnp34j.jar


export JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
ant install
ant war

