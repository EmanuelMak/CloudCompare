
build:
	@vlt run --command="make -f makefile.ci build"
deploy:
	@vlt run --command="make -f makefile.ci deploy"
createRole:
	@vlt run --command="make -f makefile.ci createRole"
test:
	@vlt run --command="make -f makefile.ci test"

# Docker Compose Build
dockerComposeBuild:
	@echo "Building Docker image with docker-compose..." && \
	docker-compose build


pushToDockerhub:
	echo $$DOCKER_TOKEN | docker login -u emanuelmak --password-stdin &&\
	docker tag camel-case-lambda-function emanuelmak/camel-case-lambda-function:latest
	@docker images
	@echo "Pushing to: dockerhub" &&\
	docker push emanuelmak/camel-case-lambda-function:latest
	@echo "Image pushed successfully."

.PHONY: build deploy createRole test dockerComposeBuild pushToDockerhub