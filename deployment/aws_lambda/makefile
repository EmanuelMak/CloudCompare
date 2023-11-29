.PHONY: createTableOnRds createTableOnRdsLocal

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


checkPythonZip:
	 unzip -l createTableOnRdsLambda.zip