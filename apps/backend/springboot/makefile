.PHONY: run

run:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		mvnw.cmd spring-boot:run; \
	else \
		./mvnw spring-boot:run; \
	fi

clean:
	@mvn clean -s ./settings.xml

test:
	@mvn test -s ./settings.xml

package:
	@mvn package -s ./settings.xml

install:
	@mvn clean install -s ./settings.xml

startDev:
	@mvn spring-boot:run -s ./settings.xml

startSpringbootDocker:
	@vlt run --command="make -f makefile.ci startSpringbootDocker"

startComposeDocker:
	@vlt run --command="make -f makefile.ci startComposeDocker"

testAwsConnected:
	@vlt run --command="aws s3 ls"

awsECRLogin:
	@vlt run --command="aws ecr get-login --region eu-central-1 --no-include-email"

createAwsEcrRepo:
	@vlt run --command="make -f makefile.ci createAwsEcrRepo"

loginToAwsEcrRepo:
	@vlt run --command="make -f makefile.ci loginToAwsEcrRepo"

createAwsBeanstalkApplication:
	@eb create your-environment-name &&\
	if [ $? -ne 0 ]; then \
    	echo "Error occurred during environment creation. Terminating environment." ;\
    	eb terminate your-environment-name -f ;\
	fi
