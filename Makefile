PYTHON = python3.11
SCRAPY = scrapy

PROJECT_DIR = collect/furet_scraper
DATA_DIR = data
SCRIPTS_DIR = scripts
REQUIREMENTS = requirements.txt
POSTGRES_CONTAINER_NAME = book-reco-postgres
POSTGRES_PASSWORD = admin
POSTGRES_VOLUME = $(shell pwd)/$(DATA_DIR)/postgres
POSTGRES_PORT = 5433
VENV = venv

.PHONY: all setup run-scrapy compress clean start-postgres stop-postgres delete-postgres help

all: setup run-scrapy compress

setup:
	@echo "Setting up the environment..."
	$(PYTHON) -m venv $(VENV)
	. $(VENV)/bin/activate && pip install -r $(REQUIREMENTS) && deactivate

run-scrapy: setup
	@echo "Running Scrapy spider..."
	. $(VENV)/bin/activate && cd $(PROJECT_DIR) && $(SCRAPY) crawl furet -o ../../$(DATA_DIR)/raw_output.json && deactivate

compress: setup
	@echo "Compressing data..."
	. $(VENV)/bin/activate && $(PYTHON) $(SCRIPTS_DIR)/compress.py && deactivate

clean:
	@echo "Cleaning up the environment..."
	rm -rf $(VENV)
	rm -f $(DATA_DIR)/raw_output.json
	rm -f $(DATA_DIR)/raw_data.parquet

start-postgres:
	@echo "Starting PostgreSQL container..."
	if [ ! -d $(POSTGRES_VOLUME) ]; then \
		mkdir -p $(POSTGRES_VOLUME); \
	fi
	if [ "$$(docker ps -aq -f name=$(POSTGRES_CONTAINER_NAME))" ]; then \
		docker start $(POSTGRES_CONTAINER_NAME); \
	else \
		docker run --name $(POSTGRES_CONTAINER_NAME) -e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) -v $(POSTGRES_VOLUME):/var/lib/postgresql/data -p $(POSTGRES_PORT):5432 -d postgres; \
	fi

stop-postgres:
	@echo "Stopping PostgreSQL container..."
	if [ "$$(docker ps -aq -f name=$(POSTGRES_CONTAINER_NAME))" ]; then \
		docker stop $(POSTGRES_CONTAINER_NAME); \
	else \
		echo "PostgreSQL container is not running."; \
	fi

delete-postgres: stop-postgres
	@echo "Deleting PostgreSQL container..."
	if [ "$$(docker ps -aq -f name=$(POSTGRES_CONTAINER_NAME))" ]; then \
		docker rm $(POSTGRES_CONTAINER_NAME); \
	else \
		echo "PostgreSQL container does not exist."; \
	fi

help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  all          Run all tasks (setup, run-scrapy, compress)"
	@echo "  setup        Set up the environment"
	@echo "  run-scrapy   Run the Scrapy spider"
	@echo "  compress     Compress the data"
	@echo "  clean        Clean up the environment"
	@echo "  start-postgres Start the PostgreSQL container"
	@echo "  stop-postgres Stop the PostgreSQL container"
	@echo "  delete-postgres Delete the PostgreSQL container"
	@echo "  help         Display this help message"
