.PHONY: run stop restart build scale pull rebuild shell list restart destroy  \
		first-run build-all composer-install composer-update migrate		  \
		seed key-generate

-include .env
include .docker.images

SHELL := /bin/bash
ENVIROMENT_MODE ?= tools

PROJECT_NAME ?= financial-trl
BASE_DOMAIN ?= trl.financial.lo

MAKE ?= make
DOCKER ?= docker
DOCKER_COMPOSE_PATH ?= docker-compose

ENVS := \
	DOCKER_REGISTRY=$(DOCKER_REGISTRY) 						\
															\
	DOCKER_IMAGES_NGINX_NAME=$(DOCKER_IMAGES_NGINX_NAME) 	\
	DOCKER_IMAGES_NGINX_TAG=$(DOCKER_IMAGES_NGINX_TAG) 		\
															\
	DOCKER_IMAGES_PHPFPM_NAME=$(DOCKER_IMAGES_PHPFPM_NAME)	\
	DOCKER_IMAGES_PHPFPM_TAG=$(DOCKER_IMAGES_PHPFPM_TAG)	\
															\
	DOCKER_IMAGES_SHELL_NAME=$(DOCKER_IMAGES_SHELL_NAME)	\
	DOCKER_IMAGES_SHELL_TAG=$(DOCKER_IMAGES_SHELL_TAG)		\
															\
	PROJECT_NAME=$(PROJECT_NAME)							\
	BASE_DOMAIN=$(BASE_DOMAIN)

DOCKER_COMPOSE :=			\
	$(ENVS) 				\
	$(DOCKER_COMPOSE_PATH)	\
	-p $(PROJECT_NAME)		\
	-f docker-compose.yml

# Cosmetics:
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions:
INFO := @bash -c '\
  printf $(YELLOW); \
  echo "=> $$1"; \
  printf $(NC)' SOME_VALUE

include makefiles/$(ENVIROMENT_MODE).mk
