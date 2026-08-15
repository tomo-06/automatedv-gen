.PHONY: up down down-v ps logs deps debug seed run test build parse clean show compiled psql

DBT  := uv run dbt
DIRS := --project-dir dbt --profiles-dir dbt

# --- コンテナ ---
up:
	docker compose up -d

down:
	docker compose down

down-v:
	docker compose down -v

ps:
	docker compose ps

logs:
	docker compose logs -f postgres

# --- dbt ---
deps:
	$(DBT) deps $(DIRS)

debug:
	$(DBT) debug $(DIRS)

seed:
	$(DBT) seed $(DIRS)

run:
	$(DBT) run $(DIRS)

test:
	$(DBT) test $(DIRS)

build:         ## make build / make build SELECT=+stg_crm_customer
	$(DBT) build $(DIRS) $(if $(SELECT),--select $(SELECT))

parse:
	$(DBT) parse $(DIRS) && $(DBT) ls $(DIRS)

clean:
	$(DBT) clean $(DIRS)

# --- 確認・デバッグ ---
show:          ## make show SQL="select * from {{ ref('stg_crm_customer') }}"
	$(DBT) show $(DIRS) --inline "$(SQL)" --limit $(or $(LIMIT),20)

compiled:      ## make compiled MODEL=stg_crm_customer
	@find dbt/target/compiled -name "$(MODEL).sql" -exec cat {} \;

psql:
	docker compose exec postgres psql -U $${POSTGRES_USER} -d $${POSTGRES_DB}
