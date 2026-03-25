include .env
export

export PROJECT_ROOT=$(CURDIR)

.PHONY: env-up env-down env-cleanup migrate-create migrate-up migrate-down migrate-action wait-postgres

env-up:
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down

env-cleanup:
	@powershell -Command "$$ans = Read-Host 'Delete all environment volume files? Data may be lost. [y/N]'; if ($$ans -eq 'y') { docker compose down; if (Test-Path 'out/pgdata') { Remove-Item 'out/pgdata' -Recurse -Force }; Write-Host 'Environment files deleted' } else { Write-Host 'Cleanup cancelled' }"

migrate-create:
	@powershell -Command "if ([string]::IsNullOrWhiteSpace('$(seq)')) { Write-Host no seq; exit 1 }"
	docker compose run --rm todoapp-postgres-migrate create -ext sql -dir /migrations -seq "$(seq)"

migrate-up:
	@make migrate-action action=up
migrate-down:
	@make migrate-action action=down

wait-postgres:
	@docker compose up -d todoapp-postgres
	@powershell -Command "$$maxAttempts = 30; for ($$attempt = 1; $$attempt -le $$maxAttempts; $$attempt++) { docker compose exec -T todoapp-postgres pg_isready -U '$(POSTGRES_USER)' -d '$(POSTGRES_DB)' > $$null 2>&1; if ($$LASTEXITCODE -eq 0) { Write-Host 'Postgres is ready'; exit 0 }; Start-Sleep -Seconds 1 }; Write-Error 'Postgres did not become ready in time'; exit 1"

migrate-action: wait-postgres
	@docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable" \
		$(action)

env-port-forwarder:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose stop port-forwarder
	@docker compose rm -f port-forwarder