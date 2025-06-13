# Stage 1: Build the application using Gradle
FROM gradle:8.5.0-jdk17 AS build
WORKDIR /app

# Copy only the contents of the src folder (adjusted path)
COPY ./src/ .  # ✅ Correct path to your Gradle project files

# Make gradlew executable (only needed on Unix-based systems, but safe)
RUN chmod +x ./gradlew

# Run the build using Gradle wrapper
RUN ./gradlew build --no-daemon

# Stage 2: Run the application with minimal JDK
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy the built jar from the previous build stage
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
