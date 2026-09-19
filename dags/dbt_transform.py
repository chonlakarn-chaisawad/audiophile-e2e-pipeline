from __future__ import annotations

from datetime import datetime, timedelta
from pathlib import Path

from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig

DBT_PROJECT_DIR = Path("/opt/airflow/dbt")

profile_config = ProfileConfig(
    profile_name="audiophile_analytics",
    target_name="dev",
    profiles_yml_filepath=DBT_PROJECT_DIR / "profiles.yml",
)

execution_config = ExecutionConfig(
    dbt_executable_path="/home/airflow/.local/bin/dbt",
)

default_args = {
    "owner": "audiophile-analytics",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

dbt_transform_dag = DbtDag(
    project_config=ProjectConfig(DBT_PROJECT_DIR),
    profile_config=profile_config,
    execution_config=execution_config,
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    default_args=default_args,
    dag_id="dbt_transform",
    tags=["dbt", "transform", "clickhouse"],
)