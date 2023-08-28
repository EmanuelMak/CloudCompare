# Makefile

# Variables
CAMELCASE_DIR = src/camelCase
SPRINGBOOT_DIR = apps/backend/springboot
CAMELCASE_SERVICE = camelcase-builder
SPRINGBOOT_SERVICE = springboot-app
SPRINGBOOT_DEV_SERVICE = springboot-dev

MAVEN_VOLUME = maven_cache
MAVEN_IMAGE = maven:3.9.3-eclipse-temurin-17

# Phony targets ensure that Make doesn't confuse them with filenames.
.PHONY: springbootAllLocal buildCamelCase buildSpringboot runSpringboot clearAll clean




################ run using docker images ################



# Start springboot app and rebuild all dependencies using Docker
springbootAllDocker: buildCamelCaseDocker buildSpringbootDocker runSpringbootDocker


# Build camelCase Maven project using Docker with caching
buildCamelCaseDocker:
# Ensure the Maven Docker image is present or pulled from DockerHub
	docker pull $(MAVEN_IMAGE)
	docker run --rm -v "$(PWD)/$(CAMELCASE_DIR)":/usr/src/mymaven -v $(MAVEN_VOLUME):/root/.m2 -w /usr/src/mymaven $(MAVEN_IMAGE) mvn clean install

# Build Spring Boot app using Docker with caching
buildSpringbootDocker:
	docker run --rm -v "$(PWD)/$(SPRINGBOOT_DIR)":/usr/src/mymaven -v $(MAVEN_VOLUME):/root/.m2 -w /usr/src/mymaven $(MAVEN_IMAGE) mvn clean package

# Run Spring Boot app using Docker
runSpringbootDocker:
	docker run --rm -v "$(PWD)/$(SPRINGBOOT_DIR)":/usr/src/myspringboot -v $(MAVEN_VOLUME):/root/.m2 -w /usr/src/myspringboot -p 8080:8080 $(MAVEN_IMAGE) mvn spring-boot:run


# Remove containers and volumes related to the direct Docker approach
clearDocker:
	# Remove Maven cache volume (from direct Docker runs)
	docker volume rm $(MAVEN_VOLUME) || true
	# Remove any stopped containers that used our Maven image (this is a best guess cleanup)
	docker ps -a | grep $(MAVEN_IMAGE) | awk '{print $$1}' | xargs -r docker rm



################ run using docker-compose DEV ################

# Command to stop Spring Boot, rebuild camelCase and restart Spring Boot
springbootDevUp: clearAllDev buildSpringbootDev runSpringbootDev

# Command to stop Spring Boot, rebuild camelCase and restart Spring Boot
updateCamelCaseAndRestartDev: 
	docker-compose stop $(SPRINGBOOT_DEV_SERVICE)
	docker run --rm -v $(PWD)/$(CAMELCASE_DIR):/usr/src/mymaven -w /usr/src/mymaven $(MAVEN_IMAGE) mvn clean install
	docker run --rm -v $(PWD)/$(SPRINGBOOT_DIR):/usr/src/myapp -w /usr/src/myapp $(MAVEN_IMAGE) mvn clean install
	docker-compose up -d $(SPRINGBOOT_DEV_SERVICE)

# Build Spring Boot app using Docker
buildSpringbootDev:
	docker-compose build $(SPRINGBOOT_DEV_SERVICE)

# Run Spring Boot app using Docker
runSpringbootDev:
	docker-compose up $(SPRINGBOOT_DEV_SERVICE)

# Stop and remove the dev containers
cleanDev:
	docker-compose rm -f -s $(SPRINGBOOT_DEV_SERVICE)

# Clear everything related to the dev approach
clearAllDev:
	# Stop and remove dev containers
	docker-compose rm -f -s $(SPRINGBOOT_DEV_SERVICE)
	# Remove dev images
	docker rmi $(SPRINGBOOT_DEV_SERVICE) --force
	# Remove dev-related volumes (Use with caution!)
	docker volume ls -qf dangling=true | grep $(MAVEN_VOLUME) | xargs -r docker volume rm

################ run using docker-compose PROD ################

# Command to stop Spring Boot, rebuild camelCase and restart Spring Boot
SpringbootProdUp: clearAllProd buildCamelCase buildSpringboot runSpringboot

# Build camelCase Maven project using Docker
buildCamelCase:
	docker-compose build $(CAMELCASE_SERVICE)
	docker-compose up -d $(CAMELCASE_SERVICE)

# Build Spring Boot app using Docker
buildSpringboot:
	docker-compose build $(SPRINGBOOT_SERVICE)

# Run Spring Boot app using Docker
runSpringboot:
	docker-compose up $(SPRINGBOOT_SERVICE)

# Stop and remove the prod containers
cleanProd:
	docker-compose rm -f -s $(SPRINGBOOT_SERVICE) $(CAMELCASE_SERVICE)

# Clear everything related to the prod approach
clearAllProd:
	# Stop and remove prod containers
	docker-compose rm -f -s $(SPRINGBOOT_SERVICE) $(CAMELCASE_SERVICE)
	# Remove prod images
	docker rmi $(CAMELCASE_SERVICE) $(SPRINGBOOT_SERVICE) --force
	# Remove prod-related volumes (Use with caution!)
	docker volume ls -qf dangling=true | grep $(MAVEN_VOLUME) | xargs -r docker volume rm

################ general util commands ################

# Clear everything related to both dev and prod
clearAll:
	# Stop and remove all containers
	docker-compose down -v --remove-orphans
	# Remove all images
	docker rmi $(CAMELCASE_SERVICE) $(SPRINGBOOT_SERVICE) $(SPRINGBOOT_DEV_SERVICE) --force
	# Remove only the project-related volumes
	docker volume rm $(MAVEN_VOLUME) || true  # The "|| true" ensures that the command won't fail if the volume doesn't exist
	# Call clearDocker to remove direct Docker runs
	$(MAKE) clearDocker

test:
	docker run -it --rm -v $(MAVEN_VOLUME):/root/.m2 $(MAVEN_IMAGE) /bin/bash
	docker run --rm -v "$(PWD)/$(SPRINGBOOT_DIR)":/usr/src/myspringboot -w /usr/src/myspringboot -p 8080:8080 $(MAVEN_IMAGE)


checkVolume:
	docker run -it -v camelcase-artifacts:/app/target/ alpine /bin/sh


dockerClearComplely:
	docker system prune -a --volumes --force




	
################ local approach ################

# start springboot app and rebuild all dependencies
springbootAllLocal: buildCamelcaseLocal buildSpringbootLocal runSpringbootLocal

# Build camelCase Maven project
buildCamelcaseLocal:
	cd $(CAMELCASE_DIR) && mvn clean install

# Build Spring Boot app
buildSpringbootLocal:
	cd $(SPRINGBOOT_DIR) && mvn clean package

# Run Spring Boot app
runSpringbootLocal:
	cd $(SPRINGBOOT_DIR) && mvn spring-boot:run

# Clean both projects
cleanLocal:
	cd $(CAMELCASE_DIR) && mvn clean
	cd $(SPRINGBOOT_DIR) && mvn clean




testEnvSecrets:
	@echo 'AWS_ID: $(AWS_ID)'
	@echo 'TEST_TEST: $(TEST_TEST)'
