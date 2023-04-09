# Builder
FROM maven:3.9-eclipse-temurin-17-alpine as builder

COPY src /usr/src/app/src
COPY pom.xml /usr/src/app

RUN mvn -f /usr/src/app/pom.xml clean package -Dmaven.test.skip

#Runner

FROM eclipse-temurin:17-jre-alpine

RUN mkdir /opt/app
COPY --from=builder /usr/src/app/target/helloworld-0.0.1-SNAPSHOT.jar /opt/app/helloworld.jar

WORKDIR /opt/app

EXPOSE 8080

CMD ["java", "-jar", "/opt/app/helloworld.jar"]
