FROM tomcat:7

# copy jdbc drivers
COPY ./WebContent/WEB-INF/lib/mysql-connector-java-5.1.38-bin.jar /usr/local/tomcat/lib/
COPY ./WebContent/WEB-INF/lib/postgresql-9.2-1000.jdbc4.jar /usr/local/tomcat/lib/

# copy contex.xml file containing db connection details
COPY docker/tomcat/ /usr/local/tomcat/

# copy war file built in step 1
COPY ./ScadaLTS.war /usr/local/tomcat/webapps/ROOT.war

# dirty hack! run for long enough to extract the war file so we can change contents later
#RUN bash -c "catalina.sh start; sleep 10; catalina.sh stop"