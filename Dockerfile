# Stage 1: Build dependencies in a virtual environment
FROM python:3.9 AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment and install packages.
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir mysqlclient \
    && pip install --no-cache-dir -r requirements.txt


# Stage 2: Clean runtime environment
FROM python:3.9-slim

WORKDIR /app/backend

# Install runtime dependencies for mysqlclient
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy source code
COPY . /app/backend

EXPOSE 8000

CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]
