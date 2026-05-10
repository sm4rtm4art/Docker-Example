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

# Install curl for health checks
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security (reuse host GID if it already exists — avoids failures on some macOS hosts)
ARG UID=1000
ARG GID=1000
RUN set -eux; \
    if getent group "${GID}" >/dev/null 2>&1; then \
      EXISTING="$(getent group "${GID}" | cut -d: -f1)"; \
      useradd -r -g "${EXISTING}" -u "${UID}" appuser; \
    else \
      groupadd -r -g "${GID}" appgroup; \
      useradd -r -g appgroup -u "${UID}" appuser; \
    fi

# Set working directory
WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Change ownership to non-root user
RUN chown -R "${UID}:${GID}" /app

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
