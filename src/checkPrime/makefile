# Variables
MVN=mvn

# Default target
all: clean build

# Clean target
clean:
	$(MVN) clean

# Compile target
compile:
	$(MVN) compile

# Build target
build:
	$(MVN) package

# Test target
test:
	$(MVN) test

# Install target
install:
	$(MVN) install

# Run target
run:
	$(MVN) spring-boot:run

# Help target
help:
	@echo "Available targets:"
	@echo "  all      - Clean and build project (default)"
	@echo "  clean    - Clean project"
	@echo "  compile  - Compile sources"
	@echo "  build    - Build project"
	@echo "  test     - Run tests"
	@echo "  install  - Install project artifacts to local repository"
	@echo "  run      - Run the application (for Spring Boot projects)"
	@echo "  help     - Display help message"


load-env:
	@direnv allow

deployToGitlabPackageRegistry: load-env
	vlt run --command="make -f makefile.ci deployToGitlabPackageRegistry"
