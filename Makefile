SHELL := /bin/bash

.DEFAULT_GOAL := help

APP_NAME := magnificent-api
export APP_ROOT = $(shell pwd)

-include $(APP_ROOT)/Makefile.override

#############################################
#             JOBS FOR CI                   #
#############################################

make-migrations:
	@python3 manage.py makemigrations

migrate:
	@python3 manage.py migrate

shell:
	@python3 manage.py shell

create-super-user: 
	@python3 manage.py createsuperuser

run-django:
	@python manage.py $(filter-out $@,$(MAKECMDGOALS))


#############################################
#             JOBS FOR LOCAL                #
#############################################

docker/up: ## Start the application.
	@docker-compose up -d
	@docker-compose logs user-web --follow

docker/start: ## Start the application.
	@docker-compose up -d

docker/stop: ## Stop the application.
	@docker-compose stop

docker/down: ## Stop and remove containers, networks, images, and volumes.
	@docker-compose down

docker/build: ## Build the application.
	@docker-compose build
	@docker-compose --profile test build

docker/test:
	@docker-compose run --rm test

docker/restart: ## Restart the application.
	@docker-compose restart

docker/make-migrations: ## Create Django migrations.
	@docker-compose run --rm user-web make make-migrations

docker/migrate: ## Run Django migrations.
	@docker-compose run --rm user-web make migrate

docker/shell: ## Open Django shell.
	@docker-compose run --rm user-web make shell

docker/create-super-user: ## create Django Super User
	@docker-compose run --rm -it user-web make create-super-user

docker/create-admin: ## create Django Admin User
	@docker-compose run --rm -it user-web make create-admin

docker/get-admin-token: ## get Django Admin Token
	@docker-compose run --rm -it user-web make get-admin-token

docker/run-django: ## Run Django command.
	@docker-compose run --rm user-web python manage.py $(filter-out $@,$(MAKECMDGOALS))

build-and-push-prod: ## Build and push docker image for production
	@docker build $(APP_ROOT) -f $(APP_ROOT)/Dockerfile -t $(IMAGE_NAME)
	@docker push $(IMAGE_NAME)

# update-argoconfig:
# 	@kubectl set image --filename k8s/dev/deployment.yaml magnificent-api=$(IMAGE_NAME) --local -o yaml > new-deployment.yaml
# 	@cat new-deployment.yaml
# 	@rm -rf k8s/dev/deployment.yaml
# 	@mv new-deployment.yaml k8s/dev/deployment.yaml
# update-argoconfig ## Deploy to kubernetes
deploy: build-and-push-prod 
	@echo "Completed!"

help:
	@echo -e "\n Usage: make [target]\n"
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'
	@echo -e "\n"