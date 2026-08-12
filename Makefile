-include .env
export

DBT_FLAGS := --project-dir dbt --profiles-dir dbt

.PHONY: up down debug deps build clean

up:
	docker compose up -d
	docker compose ps

down:
	docker compose down

debug:
	uv run dbt debug $(DBT_FLAGS)

deps:
	uv run dbt deps $(DBT_FLAGS)

build:
	uv run dbt build $(DBT_FLAGS)

clean:
	uv run dbt clean $(DBT_FLAGS)
