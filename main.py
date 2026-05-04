import os

from dagster import AssetExecutionContext, Definitions, asset
from dagster_docker import PipesDockerClient
from dotenv import load_dotenv

load_dotenv()

docker_client = PipesDockerClient()

ENDPOINTS = ["products", "carts", "users"]
AWS_BUCKET_URL = os.environ["AWS_BUCKET_URL"]
AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
AWS_SECRET_ACCESS_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]
AWS_ENDPOINT_URL = os.environ["AWS_ENDPOINT_URL"]
DUCKDB_PATH = "/app/data/lakehouse.duckdb"


def build_extraction_assets(endpoint_name: str):
    @asset(name=f"extract_{endpoint_name}")
    def _dynamic_asset(context: AssetExecutionContext, docker: PipesDockerClient):
        return docker.run(
            context=context,
            image="fake-store-extract-dev:latest",
            env={
                "API_ENDPOINT": endpoint_name,
                "DESTINATION__FILESYSTEM__BUCKET_URL": AWS_BUCKET_URL,
                "DESTINATION__FILESYSTEM__CREDENTIALS__AWS_ACCESS_KEY_ID": AWS_ACCESS_KEY_ID,
                "DESTINATION__FILESYSTEM__CREDENTIALS__AWS_SECRET_ACCESS_KEY": AWS_SECRET_ACCESS_KEY,
                "DESTINATION__FILESYSTEM__CREDENTIALS__ENDPOINT_URL": AWS_ENDPOINT_URL,
            },
            container_kwargs={"extra_hosts": {"host.docker.internal": "host-gateway"}},
        ).get_results()

    return _dynamic_asset


extraction_assets = [build_extraction_assets(endpoint) for endpoint in ENDPOINTS]


@asset(deps=extraction_assets)
def transform_data(context: AssetExecutionContext, docker: PipesDockerClient):
    return docker.run(
        context=context,
        image="fake-store-transform-dev:latest",
        env={
            "AWS_BUCKET_URL": AWS_BUCKET_URL,
            "AWS_ENDPOINT_URL": AWS_ENDPOINT_URL,
            "AWS_ACCESS_KEY_ID": AWS_ACCESS_KEY_ID,
            "AWS_SECRET_ACCESS_KEY": AWS_SECRET_ACCESS_KEY,
        },
        container_kwargs={"extra_hosts": {"host.docker.internal": "host-gateway"}},
    ).get_results()


defs = Definitions(
    assets=[*extraction_assets, transform_data],
    resources={"docker": docker_client},
)
