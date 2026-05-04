EXTRACT_IMAGE = fake-store-extract-dev:latest
TRANSFORM_IMAGE = fake-store-transform-dev:latest

# Initiate Minio instance
init:
	@echo "Ininiating local docker instance of minio..."
	cd minio && docker compose up -d
	@echo "Setup complete! Web UI: http://localhost:9001"

# Utilities for building an re-building new container images
build-extract:
	@echo "Building extraction container (dlt)..."
	cd extract && docker build -t $(EXTRACT_IMAGE) .

build-transform:
	@echo "Building transformation container (dbt)..."
	cd transform && docker build -t $(TRANSFORM_IMAGE) .

build-all: build-extract build-transform
	@echo "All Docker images built successfully!"

# Run dagster instance
dev:
	@echo "Starting Dagster UI..."
	uv run dagster dev -f main.py

# Stop instance and clear all data stored
clean-data:
	@echo "Stopping local docker instance of minio..."
	cd minio && docker compose down
	@echo "Cleaning bucket data..."
	cd minio && sudo rm -rf data
