PYTHON = python3
SCRAPY = scrapy

PROJECT_DIR = collect/furet_scraper
DATA_DIR = data
SCRIPTS_DIR = scripts
REQUIREMENTS = requirements.txt

.PHONY: all setup run-scrapy compress clean

all: setup run-scrapy compress

setup:
	@echo "Setting up the environment..."
	$(PYTHON) -m venv venv
	. venv/bin/activate
	pip install -r $(REQUIREMENTS)
	deactivate

run-scrapy:
	@echo "Running Scrapy spider..."
	. venv/bin/activate
	cd $(PROJECT_DIR) && $(SCRAPY) crawl furet -o ../../$(DATA_DIR)/raw_output.json
	deactivate

compress:
	@echo "Compressing data..."
	. venv/bin/activate
	$(PYTHON) $(SCRIPTS_DIR)/compress.py
	deactivate

clean:
	@echo "Cleaning up the environment..."
	rm -rf venv
	rm -f $(DATA_DIR)/raw_output.json
	rm -f $(DATA_DIR)/raw_data.parquet

help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  all          Run all tasks (setup, run-scrapy, compress)"
	@echo "  setup        Set up the environment"
	@echo "  run-scrapy   Run the Scrapy spider"
	@echo "  compress     Compress the data"
	@echo "  clean        Clean up the environment"
	@echo "  help         Display this help message"
