import pendulum
from airflow.sdk import dag, task
from airflow.sdk.bases.hook import BaseHook

CLICKHOUSE_CONN_ID = "clickhouse_conn"
BASE_URL = "https://crinacle.com/rankings/"


@dag(
    dag_id="audiophile_e2e_pipeline",
    schedule=None,
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    catchup=False,
    tags=["audiophile", "clickhouse"],
    doc_md="""
    get data audiophile from https://crinacle.com/rankings/ (data sources) to ClickHouse
    """,
)
def audiophile_e2e_pipeline():

    @task
    def scrape_audiophile_data() -> str:
        import re
        import pandas as pd
        import requests
        from bs4 import BeautifulSoup

        def clean_headers(headers: list) -> list:
            clean = []
            for header in headers:
                if "(" in header or "/" in header:
                    header = header.split(" ")[0]
                if header == "Setup":
                    header = "driver_type"
                clean.append(
                    re.sub(r"(?<=[a-z])(?=[A-Z])|[^a-zA-Z]", " ", header)
                    .replace(" ", "_")
                    .lower()
                )
            return clean

        def scrape(device_type: str) -> list:
            response = requests.get(BASE_URL + device_type, timeout=30)
            response.raise_for_status()
            soup = BeautifulSoup(response.text, "html.parser")

            table = soup.findChildren("table")[0]
            thead = table.find_all("thead", recursive=False)
            headers = clean_headers([cell.text for cell in thead[0].findChildren("th")])

            tbody = table.find_all("tbody", recursive=False)
            rows = tbody[0].find_all("tr", recursive=False)

            data = []
            for row in rows:
                row_data = {"device_type": device_type}
                for i, cell in enumerate(row.find_all("td", recursive=False)):
                    row_data[headers[i]] = cell.get_text()
                data.append(row_data)
            return data

        headphones = scrape("headphones")
        iems = scrape("iems")

        df = pd.DataFrame(headphones + iems)

        output_path = "/tmp/audiophile_raw.csv"
        df.to_csv(output_path, index=False)
        return output_path

    @task
    def validate_and_clean(raw_path: str) -> str:
        import pandas as pd

        df = pd.read_csv(raw_path, dtype=str)
        df = df.dropna(how="all")

        clean_path = "/tmp/audiophile_clean.csv"
        df.to_csv(clean_path, index=False)
        return clean_path

    @task
    def load_to_clickhouse(clean_path: str) -> None:
        import pandas as pd
        import clickhouse_connect

        conn = BaseHook.get_connection(CLICKHOUSE_CONN_ID)
        client = clickhouse_connect.get_client(
            host=conn.host,
            port=conn.port or 8123,
            username=conn.login,
            password=conn.password,
        )

        df = pd.read_csv(clean_path, dtype=str).fillna("")

        columns_ddl = ",\n                ".join(f"`{col}` String" for col in df.columns)
        client.command(
            f"""
            CREATE TABLE IF NOT EXISTS raw_audiophile
            (
                {columns_ddl}
            )
            ENGINE = MergeTree()
            ORDER BY device_type
            """
        )

        client.insert_df("raw_audiophile", df)

    raw_path = scrape_audiophile_data()
    clean_path = validate_and_clean(raw_path)
    load_to_clickhouse(clean_path)


audiophile_e2e_pipeline()