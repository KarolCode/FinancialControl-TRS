.PHONY:	rebuild run stop restart build scale scale.single pull status config remove destroy logs			\
	   	first.run network.prepare shell shell.tests build.all composer.install composer.update				\
	   	migrate migrate.rollback seed seed.random key.generate clear.compiled								\
	   	nginx.publish phpfpm.publish shell.publish															\
	   	webserver.generate webserver.generate.cleanup webserver.publish webserver.generate.publish 			\
	   	application.generate application.generate.cleanup application.publish application.generate.publish	\

DOCKER_COMPOSE += \
	-f docker-compose.develop.yml

DOCKER_COMPOSE_TESTS += 		\
	$(DOCKER_COMPOSE) 			\
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
	@$(DOCKER_COMPOSE) down -v

logs:
	@$(DOCKER_COMPOSE) logs -f --tail=100 $(name)

## Tools
first.run: .env
	@$(MAKE) network.prepare
	@$(MAKE) build
	@$(MAKE) run
	@$(MAKE) composer.install

network.prepare:
	@$(DOCKER) network ls | awk '{print $$2}' | grep -qe '^proxy$$' \
	|| ( \
		echo -n "Docker proxy network: "; 	\
		$(DOCKER) network create proxy		\
	)

.env:
	cp -n .env.example .env

shell:
	@$(DOCKER_COMPOSE) run --rm shell bash
	
shell.tests:
	@$(DOCKER_COMPOSE_TESTS) run --rm shell bash
	
build.all:
	@$(DOCKER_COMPOSE) pull
	@$(MAKE) build
	@$(MAKE) composer.install

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

## Generating source code pack

sourcecode.pack:
	@mkdir -p artifacts \
	&& cd src \
	&& tar -czvf ../artifacts/sourcecode.tar.gz \
		artisan		\
		app 		\
		bootstrap	\
		config		\
		database 	\
		public 		\
		routes 		\
		storage 	\
		vendor > ../artifacts/includetfiles.txt

## Generating Docker Images

## Nginx:
nginx.publish:
	@docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGES_NGINX_NAME}:${DOCKER_IMAGES_NGINX_TAG} || true \
	&& docker build docker/nginx -t ${DOCKER_REGISTRY}/${DOCKER_IMAGES_NGINX_NAME}:${DOCKER_IMAGES_NGINX_TAG} \
	&& docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGES_NGINX_NAME}:${DOCKER_IMAGES_NGINX_TAG}

## PHP-FPM:
phpfpm.publish:
	@docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGES_PHPFPM_NAME}:${DOCKER_IMAGES_PHPFPM_TAG} || true \
	&& docker build docker/php-fpm -t ${DOCKER_REGISTRY}/${DOCKER_IMAGES_PHPFPM_NAME}:${DOCKER_IMAGES_PHPFPM_TAG} \
   	&& docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGES_PHPFPM_NAME}:${DOCKER_IMAGES_PHPFPM_TAG}
   	
## Shell:
shell.publish:
	@docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGES_SHELL_NAME}:${DOCKER_IMAGES_SHELL_TAG} || true \
    && docker build docker/php-fpm -t ${DOCKER_REGISTRY}/${DOCKER_IMAGES_SHELL_NAME}:${DOCKER_IMAGES_SHELL_TAG} \
    && docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGES_SHELL_NAME}:${DOCKER_IMAGES_SHELL_TAG}

## Webserver:
webserver.generate:
	@echo "FROM $(DOCKER_REGISTRY)/$(DOCKER_IMAGES_NGINX_NAME):$(DOCKER_IMAGES_NGINX_TAG)" > Dockerfile
	@echo "COPY ./src /app" >> Dockerfile

webserver.generate.cleanup:
	@rm  -f Dockerfile

webserver.publish:
	@docker build . -t ${DOCKER_REGISTRY}/${DOCKER_IMAGES_WEBSERVER_NAME}:${tag} \
   	&& docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGES_WEBSERVER4_NAME}:${tag}

webserver.generate.publish:
	${MAKE} webserver.generate
	${MAKE} webserver.publish
	${MAKE} webserver.generate.cleanup

## Application:
application.generate:
	@echo "FROM $(DOCKER_REGISTRY)/$(DOCKER_IMAGES_PHPFPM_NAME):$(DOCKER_IMAGES_PHPFPM_TAG)" > ../Dockerfile
	@echo "COPY ./src /app" >> ../Dockerfile

application.generate.cleanup:
	@rm  -f Dockerfile

application.publish:
	@docker build . -t ${DOCKER_REGISTRY}/${DOCKER_IMAGES_APPLICATION_NAME}:${tag} \
   	&& docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGES_APPLICATION_NAME}:${tag}

application.generate.publish:
	${MAKE} application.generate
	${MAKE} application.publish
	${MAKE} application.generate.cleanup

