# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.145.1/containers/java-8/.devcontainer/base.Dockerfile

FROM mcr.microsoft.com/vscode/devcontainers/java:0-8

ARG NODE_VERSION="lts/*"
ARG TOMCAT_VERSION="7.0.94"

RUN source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1 \
    && source /usr/local/sdkman/bin/sdkman-init.sh && sdk install ant 
RUN curl -L "https://archive.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" --output /tmp/apache-tomcat.tar.gz \
    && mkdir /tmp/apache-tomcat/ && tar -C /tmp/apache-tomcat -xvf /tmp/apache-tomcat.tar.gz --strip 1 
ENV CATALINA_HOME=/tmp/apache-tomcat

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1