# Use a Maven base image
FROM --platform=linux/amd64 maven:3.8.2-openjdk-17-slim AS build

# Set the working directory
WORKDIR /app

# Copy the pom.xml file
COPY ./pom.xml .

# Download the dependencies
RUN mvn dependency:go-offline -B

# Copy the source code
COPY ./src ./src

# Build the project
RUN mvn clean install

ENTRYPOINT [ "/bin/sh" ]
