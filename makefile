# Makefile

# Variables
CAMELCASE_DIR = src/camelCase
SPRINGBOOT_DIR = apps/backend/springboot

# Phony targets ensure that Make doesn't confuse them with filenames.
.PHONY: all build-camelcase build-springboot run-springboot clean

# start springboot app and rebuild all dependencies
springboot-all-local: build-camelcase build-springboot run-springboot

# Build camelCase Maven project
build-camelcase:
	cd $(CAMELCASE_DIR) && mvn clean install

# Build Spring Boot app
build-springboot:
	cd $(SPRINGBOOT_DIR) && mvn clean package

# Run Spring Boot app
run-springboot:
	cd $(SPRINGBOOT_DIR) && mvn spring-boot:run

# Clean both projects
clean:
	cd $(CAMELCASE_DIR) && mvn clean
	cd $(SPRINGBOOT_DIR) && mvn clean