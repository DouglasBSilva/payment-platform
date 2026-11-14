.PHONY: up down restart test vet

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