# Stage 1: Build the application using Gradle
FROM gradle:8.5.0-jdk17 AS build
WORKDIR /app

# Copy entire project into container
COPY . .

# Run Gradle build without daemon
RUN gradle build --no-daemon

# Stage 2: Run the application with minimal JDK
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy the built jar from the previous stage
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
