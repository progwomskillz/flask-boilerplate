include .env
include ./deploy/.env


ENV=local
S3_BUCKET=CHANGE_ME
ECR_REPO_URL=CHANGE_ME
IMAGE=$(ECR_REPO_URL)/$(APP_NAME):$(ENV)

pull_secrets:
	aws s3 cp \
		s3://$(S3_BUCKET)/$(APP_NAME)/$(ENV)/.env \
		./secrets/$(ENV)/.env

push_secrets:
	aws s3 cp \
		./secrets/$(ENV)/.env \
		s3://$(S3_BUCKET)/$(APP_NAME)/$(ENV)/.env

use_secrets: pull_secrets
	cp ./secrets/$(ENV)/.env ./deploy/

down:
	docker-compose down

build: use_secrets
	docker-compose build

up: down build
	docker-compose up -d

unit: up
	docker-compose exec -T web pytest tests/unit/

integration: up
	docker-compose exec -T web pytest tests/integration/

test: up
	docker-compose exec -T web pytest tests/unit/
	docker-compose exec -T web pytest tests/integration/

tag: build
	docker tag $(APP_NAME):latest $(IMAGE)

push: tag
	aws ecr get-login --no-include-email --region us-east-1 | sh
	docker push $(IMAGE)

pull:
	docker pull $(IMAGE)

remove_image:
	docker rmi --force $(IMAGE)

publish: push
	ansible-playbook -i deploy/inventory/$(ENV) -s deploy/tasks/main.yml \
	--extra-vars "docker_image=$(IMAGE) aws_key=$(AWS_ACCESS_KEY_ID) aws_secret=$(AWS_SECRET_ACCESS_KEY) version=$(ENV)"

build_base: use_secrets
	ansible-playbook -i deploy/inventory/$(ENV) -s deploy/tasks/base.yml \
	--extra-vars "docker_image=$(IMAGE) aws_key=$(AWS_ACCESS_KEY_ID) aws_secret=$(AWS_SECRET_ACCESS_KEY) version=$(ENV)"
