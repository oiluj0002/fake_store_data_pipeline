# Use a Python image with uv pre-installed
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

# Setup a non-root user
RUN groupadd --system --gid 999 nonroot \
 && useradd --system --gid 999 --uid 999 --create-home nonroot

# Install the project into `/app`
RUN mkdir /app && chown nonroot:nonroot /app
WORKDIR /app

# Use the non-root user to run our application
USER nonroot

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Omit development dependencies
ENV UV_NO_DEV=1

# Ensure installed tools can be executed out of the box
ENV UV_TOOL_BIN_DIR=/usr/local/bin

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/home/nonroot/.cache/uv,uid=999,gid=999 \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project

# Then, add the rest of the project source code and install it
# Installing separately from its dependencies allows optimal layer caching
COPY --chown=nonroot:nonroot . /app
RUN --mount=type=cache,target=/home/nonroot/.cache/uv,uid=999,gid=999 \
    uv sync --locked

# Create a mount point for the data
RUN mkdir -p /app/data
RUN chown -R nonroot:nonroot /app/data
VOLUME ["/app/data"]

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Reset the entrypoint, don't invoke `uv`
ENTRYPOINT []

# Changed do dbt folder
WORKDIR /app/fake_store_dbt

# Uses `uv run` to sync dependencies on startup
CMD ["uv", "run", "dbt", "build", "--profiles-dir", ".", "--full-refresh"]
