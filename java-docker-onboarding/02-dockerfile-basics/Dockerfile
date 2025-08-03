# Use OpenJDK 17 on Ubuntu as base image
FROM openjdk:17-jdk-slim

# Set metadata
LABEL maintainer="your-email@example.com"
LABEL description="Spring Boot Docker Demo - Ubuntu based"
LABEL version="1.0"

# Create app directory
WORKDIR /app

# Copy the JAR file
# Note: You need to build the JAR first with: mvn clean package
COPY target/docker-demo-0.0.1-SNAPSHOT.jar app.jar

# Expose port 8080
EXPOSE 8080

# Create a non-root user to run the application
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

# Optional: Add JVM options
# ENTRYPOINT ["java", "-Xmx512m", "-Xms256m", "-jar", "app.jar"]