# Introduction
Scada LTS is a web application that provide a web interface to a SCADA (Supervisor control and data acquisition) system. It capture events from various devices using industry standard protocols. It then logs and reports the status of inputs/outputs on these systems.
# Development Environment Setup
1. Install OpenJDK 1.8 and set JAVA_HOME to point to install location, also make sure the bin directory is in the path.
2. Run 'java -version' to verify correct installation.
3. Install Apache Ant and set ANT_HOME to point to install location, also make sure the bin directory is in the path.
4. Run 'ant -version' to verify correct installation.
5. Download and install Apache Tomcat 7.0. This can also be done by via Eclipse add Server. Make sure you set the environment variable CATALINA_HOME to point to Tomcat installation path.
6. Install Docker this will be used to launch a local MySQL database.
7. Download and install Eclipse and install the following extensions.
* https://marketplace.eclipse.org/content/eclipse-web-developer-tools-0/promo
* https://marketplace.eclipse.org/content/spring-tools-4-aka-spring-tool-suite-4
* https://marketplace.eclipse.org/content/sonarlint
* https://marketplace.eclipse.org/content/eclipse-enterprise-java-developer-tools
8. Download and install VS Code and install the following extensions.
* eg2.vscode-npm-script
* ms-azuretools.vscode-docker
* ms-vscode-remote.remote-containers
* msjsdiag.debugger-for-chrome
* nickheap.vscode-ant
* octref.vetur
* SonarSource.sonarlint-vscode
* streetsidesoftware.code-spell-checker

# Coding Standards
1. Remove commented out code, previous code is captured by GIT.
2. Remove console debug statements, the console output should only show warnings, info and errors in production.
3. Use console logging levels in Java (log4j) and JavaScript (console) eg 
   * console.error() for runtime errors.
   * console.debug() for debug only messages. 
   * console.info() for important info needed for troubleshooting eg port number
   * console.warning() if something is invalid but can be handled.
4. Keep code DRY (Don't repeat yourself), refactor similar functions.
5. Keep JavaScript and CSS in separate files.
6. When adding new HTML elements define a unique class to the new element and reference it in you CSS selectors.
   For Example:
   `<div class="newComponent"><button class="btn btn-primary">Example</button></div>`

    In the CSS file make sure any CSS overrides are selected as follows.
   `.newComponent .btn-primary {
       font-weight: bold;
   }`

   Notice this will only apply style changes to HTML elements below newComponent.
7. Maintain consistent format eg `view.jsp`
8. Use i18n for all strings shown to users Java has messages resource bundle and vue.js has locale files.
9. Avoid using "styles" attribute in HTML define a class instead.
10. Check spelling.
11. Make sure all variables including locals have descriptive names.
12. Use naming conventions.
    * Camel case for variables, CSS class names eg (localVariable)
    * Camel Caps for class definitions and java files (MyClass).
    * Use full caps for constants (MY_CONSTANT)
    * Declare functions using verb noun format eg (getValue)
13. No magic literals numbers or strings, declare constants.
14. Add migration code when adding new fields to the database refer to V2_3__FaultsAndAlarms.java as example. 
15. Confirm migration with older version of database.
16. Remove un-needed changes before creating a pull request.
17. Make sure there are no errors or warning being raised in browser debug before pull request.
18. Suggest using SonarLint in IDE to confirm coding best practices.
19. Recommend using GIT flow to create feature branches.
20. Don't merge upstream branches only merge from `develop` branch, if you need to resolve pull request merge conflicts merge `develop` into your working branch.
21. Use JSTL and Spring MVC 4 for all code.
22. Use positive logic, by this I mean avoid using '!' operator for example.
    `if (!true) {} else {}` should be `if (true) else {}`

# Use Apache Ant to Build and Run project
You can build the WAR file locally but this step isn't needed if using Eclipse which will hot load it directly to Tomcat. 
## Prepare
1. Install node dependencies `install` into scadalts-ui/node_modules and front end node dependencies into WebContent/resources/npm/
2. Launch MySQL database server using Docker `./launch-database.sh`

## Build
3. Build `ant war` this will build all source files including scadalts-ui and Java.

## Deploy
4. You can then deploy to Tomcat using `ant tomcat-deploy`

## Run
5. Then you can start Tomcat using `ant tomcat-start`
6. Once this is done you should be able to browse to `http://localhost:8080/ScadaLTS/`

## Additional Ant targets
Most of these targets do not need to be run manually as they will be run during `ant war` build.
* clean - Clean all dependencies and output artifacts.
* tomcat-stop - To stop Tomcat.
* tomcat-clean-static-content - Clean Tomcat cache, not sure if this is needed.
* tomcat-clean-app - Delete the project files from Tomcat.
* java-build - Compiles java only files to WebContent/WEB-INF/classes.
* ui-build - Builds Vue.js webpack components to WebContent/resources/js-ui
* ui-serve - Starts Vue.js server for debugging and testing with HMR on `http://localhost:3000/`
* vue-ui-serve - Launches Vue.js web console.
* docker-build - This will create a local docker image container Tomcat and the Scada LTS war file.
* docker-run - Will launch the Docker container and you should be able to connect to it using `http://localhost:8080/ScadaLTS/`
* docker-stop - Stop and remove the Scada container.  
# Debugging Java Locally 
In Eclipse you can debug by choosing 'Debug As/Debug on server'. 
Eclipse will ask you to select the Tomcat server to run on, select 'Tomcat V7.0 Server at localhost'.
Make sure scada-lts is added to the deployed modules.

Edit the server settings by opening server view and double clicking 'Tomcat V7.0 Server at localhost'. Change timeouts to 500 seconds.

Once this has been setup a new Wclipse debug option will show in debug dropdown toolbar, select 'Tomcat V7.0 Server at localhost' this will deploy WebContent directory to `{workspace}/.metadata/.plugins/org.eclipse.wst.server.core/tmp0/wtpwebapps/scada-lts`

NOTE! any changes made outside of Eclipse will not be detected. So if you build the scadalts-ui project you will need to refresh the ScadaLTS project directory in Eclipse.

# Debugging Vue.js Components


# CI/CD
On pushing the code to the remote repository a hook will cause our local Jenkins server to build the project.
It uses the 'Dockerfile 'to build a Docker image containing the war and deploy using 'vroc-webscada.yaml' to K8s via Jenkins using the 'Jenkinsfile'. The 'vroc-build.sh' script will build the WAR files this is run by Jenkins in a Docker Ant container.

1. Jenkins detects a push to one the following branches then builds and deploys: master to production; release/*  to staging, develop to dev, feature/* build only does not deploy.
2. Jenkins read the file Jenkinsfile in the root of the project for instructions on what actions it should take when a branch is modified eg build, test, deploy, run.
3. Jenkins will run the script vroc-build.sh to build the war file inside of a Docker Ant container.
4. It will then build a new image based on the Dockerfile container Tomcat and the built war file.
5. If the branch being updated is master, release/*, or develop it will then deploy the WAR and Docker image to our repos.
6. It will then deploy to the Kubernetes cluster using the file 'vroc-webscada.yaml'