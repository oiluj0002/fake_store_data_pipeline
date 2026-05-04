# Local Lakehouse Pipeline

This project is a local data engineering pipeline built with a modern data stack. It extracts data from a REST API, loads it into a local MinIO S3 bucket, and transforms it through Medallion architecture (Bronze, Silver, Gold). The entire process is orchestrated using Dagster.

## Tech Stack
* **Orchestration:** Dagster
* **Extraction & Loading:** dlt (running in Docker)
* **Transformation:** dbt & DuckDB (running in Docker)
* **Storage:** MinIO (Local Object Storage)
* **Package Management:** uv

## Prerequisites
Before running this project, ensure you have the following installed on your machine:
* [Docker](https://docs.docker.com/get-docker/) & Docker Compose
* [uv](https://github.com/astral-sh/uv) (Python package manager)
* `make` (GNU Make)

## Quick Start

To get the pipeline running from scratch, open your terminal in the root folder and run these three commands:

1. **Start the storage server:**
   ```bash
   make init
   ```
   *(Wait a few seconds for MinIO to start. You can access the UI at http://localhost:9001)*

2. **Build the container images:**
   ```bash
   make build-all
   ```

3. **Start the Dagster orchestrator:**
   ```bash
   make dev
   ```
   *(This will open the Dagster UI where you can trigger your pipeline runs).*

## Available Commands Reference

Here is the full list of Makefile commands available to manage the project:

* **`make init`**: Starts the local MinIO Docker instance in the background.
* **`make build-extract`**: Builds only the `dlt` extraction Docker image.
* **`make build-transform`**: Builds only the `dbt` transformation Docker image.
* **`make build-all`**: Builds both the extraction and transformation Docker images.
* **`make dev`**: Starts the local Dagster UI for orchestrating the pipeline.
* **`make clean-data`**: Stops the MinIO containers and completely deletes the local `data` folder (requires `sudo` permissions). **Warning: This permanently deletes your bucket data.**
