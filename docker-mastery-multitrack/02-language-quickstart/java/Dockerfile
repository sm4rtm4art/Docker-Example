# syntax=docker/dockerfile:1
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml ./
RUN mvn --batch-mode dependency:go-offline
COPY src/ ./src/
RUN mvn --batch-mode verify

FROM eclipse-temurin:25-jre-jammy AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 10001 app && useradd --uid 10001 --gid app --no-create-home app
WORKDIR /app
COPY --from=builder /app/target/task-api-1.0.0.jar ./app.jar
USER 10001:10001
EXPOSE 8080
HEALTHCHECK --interval=5s --timeout=3s --start-period=40s --retries=6 \
    CMD ["curl", "-fsS", "--max-time", "2", "http://127.0.0.1:8080/health"]
ENTRYPOINT ["java", "-jar", "app.jar"]
