# Production Dockerfile for Rust Task API
# Multi-stage build for minimal image size

# Build stage
FROM rust:alpine AS builder

# Install build dependencies
RUN apk add --no-cache musl-dev

WORKDIR /usr/src/app

# Copy dependency files first for better caching
COPY Cargo.toml Cargo.lock ./

# Create dummy source to cache dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# Copy real source code
COPY src ./src

# Build application
RUN cargo build --release

# Runtime stage
FROM alpine:3.18

# Install runtime dependencies
RUN apk add --no-cache ca-certificates curl

# Create non-root user with configurable UID/GID
ARG UID=1000
ARG GID=1000
RUN addgroup -g ${GID} rust && adduser -D -s /bin/sh -u ${UID} -G rust rust

# Create app directory
WORKDIR /app
RUN chown rust:rust /app

# Copy binary from builder stage
COPY --from=builder --chown=rust:rust /usr/src/app/target/release/task-api .

# Switch to non-root user
USER rust:rust

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run application
CMD ["./task-api"]
