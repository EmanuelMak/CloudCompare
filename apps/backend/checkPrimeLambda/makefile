
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
	docker tag checkprimelambda-checkprime-lambda-function emanuelmak/checkprime-lambda-function:latest
	@docker images
	@echo "Pushing to: dockerhub" &&\
	docker push emanuelmak/checkprime-lambda-function:latest
	@echo "Image pushed successfully."
pushToDockerhubCreateTableLambda:
	echo $$DOCKER_TOKEN | docker login -u emanuelmak --password-stdin &&\
	docker tag checkprimelambda-create-table-lambda  emanuelmak/create-table-lambda:latest
	@docker images
	@echo "Pushing to: dockerhub" &&\
	docker push emanuelmak/create-table-lambda:latest
	@echo "Image pushed successfully."

testFunctionLocally:
	@echo "Testing function locally..." &&\
	curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '7'
createTableOnDbLocally:
	@echo "creating Table on Db ..." &&\
	curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

.PHONY: build deploy createRole test dockerComposeBuild pushToDockerhub