# apps/backend/springboot/Dockerfile

# Use the official JDK 17 base image
FROM openjdk:17-jdk-slim AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy local code to the container
COPY . .

# Package the application
RUN ./mvnw clean package

# Start with a base image containing Java runtime
FROM openjdk:17-jdk-slim

# Add a volume pointing to /tmp
VOLUME /tmp

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Set the application's jar file
ARG JAR_FILE=target/*.jar

# Copy the application JAR (built in the builder stage) to the container
COPY --from=builder /app/$JAR_FILE app.jar

# Run the jar file 
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]