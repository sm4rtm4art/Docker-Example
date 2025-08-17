# Production Dockerfile for Python Task API
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user with configurable UID/GID
# Default to 1000 but allow override for different systems
ARG UID=1000
ARG GID=1000
RUN groupadd -r -g ${GID} fastapi && \
    useradd -r -g fastapi -u ${UID} fastapi

# Create app directory
WORKDIR /app

# Install Python dependencies - UV first (modern), pip fallback
COPY pyproject.toml requirements.txt ./

# Install UV and use it preferentially
RUN pip install uv || echo "UV unavailable, falling back to pip" && \
    if command -v uv >/dev/null 2>&1; then \
        echo "📦 Using UV (modern package manager)" && \
        uv pip install --system --no-cache -r requirements.txt; \
    else \
        echo "📦 Using pip (traditional package manager)" && \
        pip install --no-cache-dir -r requirements.txt; \
    fi

# Copy application code
COPY --chown=fastapi:fastapi src/ ./src/

# Switch to non-root user
USER fastapi:fastapi

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Run application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
