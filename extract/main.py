import json
import os
from typing import Any

import dlt
from dlt.sources.rest_api import rest_api_source

from utils.logger import get_logger

logger = get_logger()
API_ENDPOINT = os.environ["API_ENDPOINT"]


def convert_to_string(record: dict[str, Any]):
    return {
        key: json.dumps(value) if isinstance(value, dict) else str(value)
        for key, value in record.items()
        if value is not None
    }


def main():
    try:
        logger.info("Starting Rest API pipeline execution.")
        source = rest_api_source(
            {
                "client": {
                    "base_url": "https://fakestoreapi.com/",
                    "paginator": "single_page",
                },
                "resources": [f"{API_ENDPOINT}"],
            }
        )
        source.resources[API_ENDPOINT].add_map(convert_to_string)
        pipeline = dlt.pipeline(
            pipeline_name="fake_store_pipeline",
            destination="filesystem",
        )
        load_info = pipeline.run(
            source,
            write_disposition="replace",
            loader_file_format="parquet",
            dataset_name="bronze",
        )
        for line in str(load_info).splitlines():
            logger.info(line)
        logger.info("Pipeline finished successfully")
    except Exception:
        logger.exception("Unhandled error during pipeline execution.")
        raise


if __name__ == "__main__":
    main()
