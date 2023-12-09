# Makefile for running Locust tests with Docker

# Test configuration variables
TEST_APPLICATION ?= camelcase
TEST_SCENARIO ?= continuous
REQ_AMOUNT ?= 10
TEST_EXECUTION_TIME ?= 10#in seconds



SPAWN_RATE ?= 10
NUM_USERS ?= 10

# Docker configuration
DOCKER_IMAGE := locustio/locust
LOCUST_FILE := ./locustTests.py
CSV_SENTENCES_FILE := ./test_sentences.csv


DOCKER_USER_REPO := emanuelmak
CUSTOM_LOCUST_IMAGE_NAME := $(DOCKER_USER_REPO)/locust-tests
IMAGE_TAG := latest

# Results and logs paths
TEST_RES_PATH := ./results/res
TEST_LOG_PATH := ./results/logs

EKS_BASE_URL := http://a8f2f0b0e1e9a11eaae7c0a2b6a0b6e1-2125827402.eu-central-1.elb.amazonaws.com
LAMBDA_BASE_URL := https://nmsl2sbb91.execute-api.eu-central-1.amazonaws.com/prod
LAMBDA_REQUEST_PATH := /camelcase
BASE_URL ?= $(LAMBDA_BASE_URL)
REQUEST_PATH ?= /camelcase

REQ_AMOUNT ?= 1
TEST_EXECUTION_TIME ?= 10#in seconds
# Interactive input for execution time and request amount
runLocustTest:
	@echo -n "Enter the request amount (REQ_AMOUNT) [Default: $(DEFAULT_REQ_AMOUNT)]: "; \
	read input_req_amount; \
	REQ_AMOUNT=$${input_req_amount:-$(DEFAULT_REQ_AMOUNT)}; \
	echo -n "Enter the test execution time in seconds (TEST_EXECUTION_TIME) [Default: $(DEFAULT_TEST_EXECUTION_TIME)]: "; \
	read input_test_execution_time; \
	TEST_EXECUTION_TIME=$${input_test_execution_time:-$(DEFAULT_TEST_EXECUTION_TIME)}; \
	if [ $$REQ_AMOUNT -lt 30 ]; then \
		NUM_USERS=1; \
		SPAWN_RATE=1; \
	else \
		NUM_USERS=$(NUM_USERS); \
		SPAWN_RATE=$(SPAWN_RATE); \
	fi; \
	$(MAKE) executeLocustTest REQ_AMOUNT=$$REQ_AMOUNT TEST_EXECUTION_TIME=$$TEST_EXECUTION_TIME NUM_USERS=$$NUM_USERS SPAWN_RATE=$$SPAWN_RATE


executeLocustTest:
	mkdir -p $(TEST_LOG_PATH) $(TEST_RES_PATH) $(TEST_RES_PATH)/full;
	@docker run \
		-v $(shell pwd)/$(CSV_SENTENCES_FILE):/mnt/locust/$(CSV_SENTENCES_FILE) \
		-v $(shell pwd)/$(LOCUST_FILE):/mnt/locust/$(LOCUST_FILE) \
		-v $(shell pwd)/$(TEST_LOG_PATH):/mnt/locust/logs \
		-v $(shell pwd)/$(TEST_RES_PATH):/mnt/locust/results \
		-e TEST_EXECUTION_TIME=$(TEST_EXECUTION_TIME) \
		-e REQ_AMOUNT=$(REQ_AMOUNT) \
		-e REQUEST_PATH=$(REQUEST_PATH) \
		-e TEST_APPLICATION=$(TEST_APPLICATION) \
		-e NUM_USERS=$(NUM_USERS) \
		-e TEST_TYPE=$(TEST_SCENARIO) \
		-e HOST=$(BASE_URL) \
		-e CSV_SENTENCES_FILE=/mnt/locust/$(CSV_SENTENCES_FILE) \
		$(CUSTOM_LOCUST_IMAGE_NAME):$(IMAGE_TAG) \
		-f /mnt/locust/$(LOCUST_FILE) \
		--headless \
		--spawn-rate $(SPAWN_RATE) \
		--run-time $(TEST_EXECUTION_TIME)s \
		--u $(NUM_USERS) \
		--csv /mnt/locust/results/$(TEST_APPLICATION)_$(TEST_SCENARIO)_$(REQ_AMOUNT)req_$(TEST_EXECUTION_TIME)s \
		--csv-full-history \
		--loglevel INFO \
		--logfile /mnt/locust/logs/$(TEST_APPLICATION)_$(TEST_SCENARIO)_$(REQ_AMOUNT)req_log.log \


# Phony targets for different test scenarios

#lambda test requests
runCamelcaseContinuousReqLambda:
	@$(MAKE) runLocustTest TEST_APPLICATION=camelcase TEST_SCENARIO=continuous BASE_URL=$(LAMBDA_BASE_URL)

runCamelcaseLoadReqLambda:
	@$(MAKE) runLocustTest TEST_APPLICATION=camelcase TEST_SCENARIO=load BASE_URL=$(LAMBDA_BASE_URL)

runCheckPrimeContinuousReqLambda:
	@$(MAKE) runLocustTest TEST_APPLICATION=checkprime TEST_SCENARIO=continuous BASE_URL=$(LAMBDA_BASE_URL)

runCheckPrimeLoadReqLambda:
	@$(MAKE) runLocustTest TEST_APPLICATION=checkprime TEST_SCENARIO=load BASE_URL=$(LAMBDA_BASE_URL)

# eks test requests
runCamelcaseContinuousReqeks:
	@$(MAKE) runLocustTest TEST_APPLICATION=camelcase TEST_SCENARIO=continuous BASE_URL=$(EKS_BASE_URL)

runCamelcaseLoadReqeks:
	@$(MAKE) runLocustTest TEST_APPLICATION=camelcase TEST_SCENARIO=load BASE_URL=$(EKS_BASE_URL)

runCheckPrimeContinuousReqeks:
	@$(MAKE) runLocustTest TEST_APPLICATION=checkprime TEST_SCENARIO=continuous BASE_URL=$(EKS_BASE_URL)

runCheckPrimeLoadReqeks:
	@$(MAKE) runLocustTest TEST_APPLICATION=checkprime TEST_SCENARIO=load BASE_URL=$(EKS_BASE_URL)

# Build and push Docker image
buildAndPushDockerImage:
	@echo "Logging in to Docker Hub..."
	echo $$DOCKER_TOKEN | docker login -u $(DOCKER_USER_REPO) --password-stdin &&\
	echo "Building Docker image..." &&\
	docker build -t $(CUSTOM_LOCUST_IMAGE_NAME):$(IMAGE_TAG) . &&\
	echo "Pushing Docker image to Docker Hub..." &&\
	docker push $(CUSTOM_LOCUST_IMAGE_NAME):$(IMAGE_TAG)

test:
	@echo "hello world"

.PHONY: runCamelcaseContinuousReq runCamelcaseLoadReq runCheckPrimeContinuousReq runCheckPrimeLoadReq runLocustTest buildAndPushDockerImage
