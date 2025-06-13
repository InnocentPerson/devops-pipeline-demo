# Stage 1: Build the application using Gradle
FROM gradle:8.5.0-jdk17 AS build
WORKDIR /app

# Copy your actual Gradle project files (adjusted for your structure)
COPY src/ .  

# Make gradlew executable
RUN chmod +x ./gradlew

# Build the project
RUN ./gradlew build --no-daemon

# Stage 2: Run the built jar
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
