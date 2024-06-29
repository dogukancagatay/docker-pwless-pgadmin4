from collections.abc import Generator
from dataclasses import dataclass
from http import HTTPStatus
import time
from typing import Any
import requests
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs
from testcontainers.core.image import DockerImage
from testcontainers.postgres import PostgresContainer

from testcontainers.selenium import BrowserWebDriverContainer
from selenium.webdriver import DesiredCapabilities

import pytest
import logging


LOGGER = logging.getLogger(__name__)


@dataclass
class PgConfig:
    username: str
    password: str
    dbname: str
    image: str = "postgres:latest"
    driver: Any = None


@pytest.fixture(scope="session", name="pg_config")
def fixture_pg_config() -> PgConfig:
    return PgConfig(
        username="test",
        password="test",
        dbname="test",
    )


@pytest.fixture(scope="session", name="pgadmin4_image")
def fixture_pgadmin4_image() -> Generator[DockerImage, Any, Any]:
    image = DockerImage(path="../", tag="test-image")
    #    logs = image.get_logs()
    yield image.build()
    image.remove()


@pytest.fixture(scope="session", name="pg_container")
def fixture_pg_container(pg_config: PgConfig) -> Generator[PostgresContainer, Any, Any]:
    container = PostgresContainer(
        pg_config.image,
        username=pg_config.username,
        password=pg_config.password,
        dbname=pg_config.dbname,
        driver=pg_config.driver,
    )

    container.start()
    delay = wait_for_logs(
        container, "database system is ready to accept connections", timeout=60
    )
    LOGGER.info("Started PG container (%s) in %s seconds", container, delay)

    yield container
    container.stop()


@pytest.fixture(scope="session", name="pgadmin4_container")
def fixture_pgadmin4_container(
    pgadmin4_image: DockerImage, pg_container: PostgresContainer, pg_config: PgConfig
) -> Generator[DockerContainer, Any, Any]:
    container = DockerContainer(str(pgadmin4_image))
    container.with_exposed_ports(80)

    container.with_env("POSTGRES_USER", pg_config.username)
    container.with_env("POSTGRES_PASSWORD", pg_config.password)
    container.with_env("POSTGRES_HOST", pg_container.get_container_host_ip())
    container.with_env("POSTGRES_PORT", str(pg_container.port))

    container.start()
    delay = wait_for_logs(container, "Starting gunicorn")
    LOGGER.info("Started pgadmin4 container (%s) in %s seconds", container, delay)

    yield container
    container.stop()


@pytest.fixture(scope="module", name="browser_container")
def fixture_browser_container() -> Generator[BrowserWebDriverContainer, Any, Any]:
    container = BrowserWebDriverContainer(DesiredCapabilities.CHROME)
    container.start()
    LOGGER.info("Started browser container (%s)", container)
    yield container
    container.stop()


def test_pgadmin4_started(pgadmin4_container: DockerContainer) -> None:
    pgadmin4_url = f"http://{pgadmin4_container.get_container_host_ip()}:{pgadmin4_container.get_exposed_port(80)}"
    print("pgadmin4 URL: %s", pgadmin4_url)

    r = requests.get(pgadmin4_url, timeout=120)
    assert r.status_code == HTTPStatus.OK
    r.raise_for_status()


def test_ui(
    pgadmin4_container: DockerContainer, browser_container: BrowserWebDriverContainer
) -> None:
    pgadmin4_url = f"http://{pgadmin4_container.get_container_host_ip()}:{pgadmin4_container.get_exposed_port(80)}"
    time.sleep(30)
    webdriver = browser_container.get_driver()
    webdriver.get(pgadmin4_url)
