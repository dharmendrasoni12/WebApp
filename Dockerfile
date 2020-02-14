FROM tomcat:jdk8-openjdk-slim
COPY ./target/*.war   /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh","run"]
