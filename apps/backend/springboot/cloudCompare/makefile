.PHONY: run

run:
	@if [ "$(OS)" = "Windows_NT" ]; then \
		mvnw.cmd spring-boot:run; \
	else \
		./mvnw spring-boot:run; \
	fi
clean:
	mvn clean
test:
	mvn test
package:
	mvn package
install:
	mvn install
