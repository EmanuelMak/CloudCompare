.PHONY: clean package run deploy

# Clean target directories
clean:
	mvn clean

# Compile and package the Azure Function
package:
	mvn clean package

# Run the Azure Function locally
run:
	mvn azure-functions:run

# Deploy the Azure Function to Azure
deploy:
	mvn azure-functions:deploy

undeploy:
	az group delete --name java-functions-group

login:
	az login