# Makefile for running Locust tests with Docker

# Test configuration variables
TEST_APPLICATION ?= camelcase
TEST_SCENARIO ?= continuous
REQ_AMOUNT ?= 10
TEST_EXECUTION_TIME ?= 60s
LAMBDA_BASE_URL := https://nmsl2sbb91.execute-api.eu-central-1.amazonaws.com/prod
CSV_FILE_PATH := ./funny_sentences.csv

# Docker configuration
DOCKER_IMAGE := locustio/locust
LOCUST_FILE := locustfile.py

DOCKER_USER_REPO := emanuelmak
CUSTOM_LOCUST_IMAGE_NAME := $(DOCKER_USER_REPO)/locust-tests
IMAGE_TAG := latest


# Run Locust test in Docker container
runLocustTest:
	@docker run -p 8089:8089 -v $(shell pwd):/mnt/locust $(DOCKER_IMAGE) \
		-f /mnt/locust/$(LOCUST_FILE) --headless \
		--users $(REQ_AMOUNT) --spawn-rate 1 \
		--run-time $(TEST_EXECUTION_TIME) \
		--host $(LAMBDA_BASE_URL) \
		--csv /mnt/locust/$(TEST_APPLICATION)_$(TEST_SCENARIO) \
		--loglevel INFO \
		--logfile /mnt/locust/$(TEST_APPLICATION)_$(TEST_SCENARIO)_log.log

# Phony targets for different test scenarios
runCamelcaseContinuousReq:
	@$(MAKE) runLocustTest TEST_APPLICATION=camelcase TEST_SCENARIO=continuous

runCamelcaseLoadReq:
	@$(MAKE) runLocustTest TEST_APPLICATION=camelcase TEST_SCENARIO=load

runCheckPrimeContinuousReq:
	@$(MAKE) runLocustTest TEST_APPLICATION=checkprime TEST_SCENARIO=continuous

runCheckPrimeLoadReq:
	@$(MAKE) runLocustTest TEST_APPLICATION=checkprime TEST_SCENARIO=load

# Build and push Docker image
buildAndPushDockerImage:
	@echo "Logging in to Docker Hub..."
	echo $$DOCKER_TOKEN | docker login -u $(DOCKER_USER_REPO) --password-stdin &&\
	echo "Building Docker image..." &&\
	docker build -t $(CUSTOM_LOCUST_IMAGE_NAME):$(IMAGE_TAG) . &&\
	echo "Pushing Docker image to Docker Hub..." &&\
	docker push $(CUSTOM_LOCUST_IMAGE_NAME):$(IMAGE_TAG)
	

.PHONY: runCamelcaseContinuousReq runCamelcaseLoadReq runCheckPrimeContinuousReq runCheckPrimeLoadReq runLocustTest buildAndPushDockerImage
