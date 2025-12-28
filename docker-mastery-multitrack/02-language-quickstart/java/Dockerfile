# Production Dockerfile for Java Task API
# Multi-stage build for optimized image size

# Build stage - using Maven image to avoid wrapper dependencies
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy configuration first for better caching
COPY pom.xml .

# Download dependencies (cached layer)
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage - smaller image
FROM eclipse-temurin:17-jre-jammy

# Create non-root user for security
# UID 1000 is standard
ARG UID=1000
ARG GID=1000
RUN groupadd -r -g ${GID} appgroup && \
    useradd -r -g appgroup -u ${UID} appuser

# Set working directory
WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
