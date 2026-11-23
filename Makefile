ENV_FILE ?= deploy/.env
-include $(ENV_FILE)

.PHONY: up down restart test vet migrate migrate-down migrate-status

up:
	docker compose -f deploy/docker-compose.yml up -d

down:
	docker compose -f deploy/docker-compose.yml down

restart:
	docker compose -f deploy/docker-compose.yml restart

test:
	go test ./...

vet:
	go vet ./...

migrate:
	goose -dir ledger/migrations postgres "$(LEDGER_MIGRATOR_URL)" up

migrate-down:
	goose -dir ledger/migrations postgres "$(LEDGER_MIGRATOR_URL)" down

migrate-status:
	goose -dir ledger/migrations postgres "$(LEDGER_MIGRATOR_URL)" status
