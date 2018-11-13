.PHONY:	rebuild run stop restart build scale scale.single pull status config remove destroy logs database.remove	\
	   	first.run network.prepare build.all shell shell.tests composer.install composer.update 						\
	   	migrate migrate.rollback seed seed.random
	   		
DOCKER_COMPOSE += \
	-f docker-compose.develop.yml \
	-f docker-compose.tools.yml

ifeq ($(USE_BUILD_DOCKER_IMAGES), true)

	DOCKER_COMPOSE += \
		-f docker-compose.build.yml	
endif

DOCKER_COMPOSE_TESTS :=	\
	$(DOCKER_COMPOSE) \
	-f docker-compose.tests.yml

.DEFAULT_GOAL := first.run

rebuild: build run
	
run:
	@$(DOCKER_COMPOSE) up -d $(name)

stop:
	@$(DOCKER_COMPOSE) stop $(name)

restart:
	@$(DOCKER_COMPOSE) restart $(name)

build:
	@$(DOCKER_COMPOSE) build $(name)

scale:
	@$(DOCKER_COMPOSE) up --scale $(name)=$(n) -d

scale.single:
	@$(DOCKER_COMPOSE) scale $(name)=$(n)

pull:
	@$(DOCKER_COMPOSE) pull

status:
	@$(DOCKER_COMPOSE) ps

config:
	@$(DOCKER_COMPOSE) config

remove:
	@$(DOCKER_COMPOSE) rm -f $(name)

destroy:
	@$(DOCKER_COMPOSE) down -v --rmi local

logs:
	@$(DOCKER_COMPOSE) logs -f --tail=100 $(name)

database.destroy:
	@$(DOCKER_COMPOSE) stop database
	@$(DOCKER_COMPOSE) rm -f database
	@$(DOCKER) volume ls | awk '{print $$2}' | grep -qe "^$(PROJECT_NAME)_database$$" \
	&& ( \
		echo -n "Removing the Docker volume: "; 			\
		$(DOCKER) volume rm $(PROJECT_NAME)_database 		\
	)

# Tools
first.run: .env
	@$(MAKE) network.prepare
	@$(MAKE) build
	@$(MAKE) run
	@$(MAKE) composer.install
	@$(MAKE) migrate
	
network.prepare:
	@$(DOCKER) network ls | awk '{print $$2}' | grep -qe '^proxy$$' \
	|| ( \
		echo -n "Docker proxy network: "; 	\
		$(DOCKER) network create proxy		\
	)

.env:
	cp -n .env.example .env

build.all:
	@$(MAKE) build
	@$(MAKE) composer.install

shell:
	@$(DOCKER_COMPOSE) run --rm shell bash
	
shell.tests:
	@$(DOCKER_COMPOSE_TESTS) run --rm shell bash

composer.install:
	@$(DOCKER_COMPOSE) run --rm shell composer install

composer.update:
	@$(DOCKER_COMPOSE) run --rm shell composer update

migrate:
	@$(DOCKER_COMPOSE) run --rm shell php artisan migrate --force

migrate.rollback:
	@$(DOCKER_COMPOSE) run --rm shell php artisan migrate:rollback

seed:
	@$(DOCKER_COMPOSE) run --rm shell php artisan db:seed

seed.random:
	@$(DOCKER_COMPOSE) run --rm shell php artisan db:seed --class=DatabaseRandomSeeder
