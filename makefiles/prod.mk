.PHONY: run stop rebuild scale scale.single restart build status config remove destroy shell logs	\
		migrate migrate.rollback cache.clear
	
run:
	@$(DOCKER_COMPOSE) up --no-deps -d

stop:
	@$(DOCKER_COMPOSE) stop

rebuild: build run

restart:
	@$(DOCKER_COMPOSE) restart

build:
	@$(DOCKER_COMPOSE) build

scale:
	@$(DOCKER_COMPOSE) up --scale $(name)=$(n) -d

scale.single:
	@$(DOCKER_COMPOSE) scale $(name)=$(n)

status:
	@$(DOCKER_COMPOSE) ps

config:
	@$(DOCKER_COMPOSE) config

remove:
	@$(DOCKER_COMPOSE) rm -f $(name)

destroy:
	@$(DOCKER_COMPOSE) down -v

shell:
	@$(DOCKER_COMPOSE) run --rm application bash

logs:
	@$(DOCKER_COMPOSE) logs -f --tail=100 $(name)

migrate:
	@$(DOCKER_COMPOSE) run --rm application php artisan migrate --force
	
migrate.rollback:
	@$(DOCKER_COMPOSE) run --rm shell php artisan migrate:rollback

