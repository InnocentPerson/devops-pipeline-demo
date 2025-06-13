# Stage 1: Build the application using Gradle
FROM gradle:8.5.0-jdk17 AS build
WORKDIR /app

# Copy project files into the container
COPY . .

# Ensure wrapper script is executable (especially for Linux)
RUN chmod +x ./gradlew

# Use Gradle Wrapper to build the project
RUN ./gradlew build --no-daemon

# Stage 2: Run the application with minimal JDK
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy the built JAR from the build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose the app port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
