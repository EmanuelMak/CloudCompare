# Makefile for JMeter Tests

# Default values for variables
REQ_AMOUNT ?= 10
TEST_EXECUTION_TIME ?= 60 # in seconds
LAMBDA_BASE_URL := https://nmsl2sbb91.execute-api.eu-central-1.amazonaws.com/prod/
CONTINUOUSREQ_AWS_LAMBDA_PATH := ./continuosReq/aws_lambda
CONTINUOUSREQ_AWS_LAMBDA_JMX_FILE := $(CONTINUOUSREQ_AWS_LAMBDA_PATH)/continuousRequestsLambda.jmx
CSV_FILE_PATH := $(shell pwd)/sentences.csv

# Test execution targets
runCamelcaseMaxLoad:
	@$(MAKE) runLambdatest TEST_APPLICATION=camelcase TEST_TYPE=maxLoad

runCamelcaseContinuousReq:
	@$(MAKE) runLambdatest TEST_APPLICATION=camelcase TEST_TYPE=continuousreq

runCheckPrimeMaxLoad:
	@$(MAKE) runLambdatest TEST_APPLICATION=checkprime TEST_TYPE=maxLoad

runCheckPrimeContinuousReq:
	@$(MAKE) runLambdatest TEST_APPLICATION=checkprime TEST_TYPE=continuousreq

# Generic target to run JMeter test based on variables
runLambdatest:
	@echo "Running JMeter Test: $(TEST_APPLICATION) with $(TEST_TYPE)..."
	@jmeter -t $(CONTINUOUSREQ_AWS_LAMBDA_JMX_FILE) \
	    -l $(CONTINUOUSREQ_AWS_LAMBDA_PATH)/$(TEST_APPLICATION)_$(TEST_TYPE)_results.jtl \
	    -JcsvFilePath=$(CSV_FILE_PATH) \
	    -JtestScenario=$(TEST_APPLICATION) \
	    -JtestType=$(TEST_TYPE) \
	    -JreqAmount=$(REQ_AMOUNT) \
	    -JexecutionTime=$(TEST_EXECUTION_TIME) \
	    -JbaseUrl=${LAMBDA_BASE_URL} \
	    -JsimpleDataWriterPath=$(CONTINUOUSREQ_AWS_LAMBDA_PATH)/$(TEST_APPLICATION)_$(TEST_TYPE)_data_writer_res.jtl \
	    -j $(CONTINUOUSREQ_AWS_LAMBDA_PATH)/$(TEST_APPLICATION)_$(TEST_TYPE)_log.log \
	    --loglevel org.apache.jmeter=INFO


# Target to open JMeter GUI with the test plan
gui:
	@jmeter -t $(CONTINUOUSREQ_AWS_LAMBDA_JMX_FILE)

# Phony targets
.PHONY: all runCamelcaseMaxLoad runCamelcaseContinuousReq runCheckPrimeMaxLoad runCheckPrimeContinuousReq runLambdatest gui
