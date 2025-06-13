# Use multi-stage build to reduce image size
FROM maven:3.8.6-openjdk-17 AS build
WORKDIR /workspace
COPY src .
RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim
COPY --from=build /workspace/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]