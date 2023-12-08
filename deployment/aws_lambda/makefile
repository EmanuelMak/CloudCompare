.PHONY: createTableOnRds createTableOnRdsLocal testCamelCase


createTableOnRds:
	@echo "Packing Python script with its dependencies..."
	@docker run -it --rm \
		-v ${PWD}:/workdir:Z \
		public.ecr.aws/sam/build-python3.8:latest \
		/bin/sh -c "pip install psycopg2-binary -t /workdir/build && cp /workdir/createTable_lambda.py /workdir/build && cd /workdir/build && zip -r /workdir/createTableOnRdsLambda.zip ."
	@echo "Python Lambda function package (createTableOnRdsLambda.zip) is ready."

createTableOnRdsLocal:
	@echo "Running Python script to create table in local Docker Compose setup..."
	@docker run -it --rm \
		-v ${PWD}:/workdir:Z \
		--network="host" \
		-e DB_HOST=db \
		-e DB_USERNAME=${DB_USERNAME} \
		-e DB_PASSWORD=${DB_PASSWORD} \
		-e DB_NAME=${DB_NAME} \
		lambci/lambda:python3.8 \
		/workdir/createTable_lambda.lambda_handler
	@echo "Python script executed to create table in local setup."


pushLambdaImagesToEcr:
	cd ./ecr &&\
	chmod +x ./pushImagesToAwsEcr.sh &&\
	./pushImagesToAwsEcr.sh

destroyLambdaFunctionsOnly:
	terraform destroy -target=aws_lambda_function.camel_case_lambda -target=aws_lambda_function.check_prime_lambda -target=aws_lambda_function.db_setup_lambda
redeployLambda:
	terraform taint aws_lambda_function.db_setup_lambda 
	terraform taint aws_lambda_function.check_prime_lambda
	terraform taint aws_lambda_function.camel_case_lambda
	terraform apply  -auto-approve 

testCamelCase:
	echo '{"queryStringParameters": {"text": "my text"}}' > payload.json &&\
	aws lambda invoke \
		--function-name "camelCaseLambdaFunction" \
		--payload fileb://payload.json \
		--log-type Tail outputfile.txt &&\
	cat outputfile.txt | jq -r '.LogResult' | base64 --decode &&\
	rm outputfile.txt payload.json
testCamelCase1:
	echo '{"queryStringParameters": {"text": "my text"}}' > payload.json &&\
	aws lambda invoke \
		--function-name "camelCaseLambdaFunction" \
		--payload fileb://payload.json \
		--log-type Tail outputfile.txt
	cat outputfile.txt
	rm payload.json