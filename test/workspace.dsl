workspace "Cloud Application Deployment" "Visualizing the deployment architecture of a cloud application." {

    model {
        user = person "User" "Interacts with the application."

        cloudApplication = softwareSystem "Cloud Application" "The entire cloud application architecture." {

            apiGateway = container "API Gateway" "Routes incoming API requests." "AWS API Gateway" {
                tags "API Gateway"
            }

            camelCaseLambda = container "CamelCase Lambda" "Handles camel-casing of text." "AWS Lambda Function" {
                tags "Lambda"
            }

            checkPrimeLambda = container "CheckPrime Lambda" "Checks if a number is prime." "AWS Lambda Function" {
                tags "Lambda"
            }

            createTableLambda = container "CreateTable Lambda" "Sets up the database schema." "AWS Lambda Function" {
                tags "Lambda"
            }

            database = container "Database" "Stores prime numbers." "AWS RDS PostgreSQL" {
                tags "Database"
            }

            user -> apiGateway "Sends requests to"
            apiGateway -> camelCaseLambda "Routes to"
            apiGateway -> checkPrimeLambda "Routes to"
            checkPrimeLambda -> database "Reads from and writes to"
            createTableLambda -> database "Configures"
        }

        live = deploymentEnvironment "Live" {

            deploymentNode "Amazon Web Services" {
                tags "Amazon Web Services - Cloud"

                deploymentNode "AWS VPC" "Virtual Private Cloud" {
                    tags "Amazon Web Services - VPC"

                    deploymentNode "Private Subnet" {
                        tags "Amazon Web Services - Subnet"

                        lambda1 = deploymentNode "AWS Lambda 1" "Lambda for CamelCase" {
                            tags "Amazon Web Services - Lambda"
                            containerInstance cloudApplication.camelCaseLambda
                        }

                        lambda2 = deploymentNode "AWS Lambda 2" "Lambda for CheckPrime" {
                            tags "Amazon Web Services - Lambda"
                            containerInstance cloudApplication.checkPrimeLambda
                        }

                        lambda3 = deploymentNode "AWS Lambda 3" "Lambda for CreateTable" {
                            tags "Amazon Web Services - Lambda"
                            containerInstance cloudApplication.createTableLambda
                        }
                    }

                    rds = deploymentNode "AWS RDS PostgreSQL" {
                        tags "Amazon Web Services - RDS"
                        containerInstance cloudApplication.database
                    }
                }
            }
        }
    }

    views {
        systemContext cloudApplication {
            include *
            autoLayout lr
        }

        deployment cloudApplication "Live" "AmazonWebServicesDeployment" {
            include *
            autoLayout lr

            animation {
                apiGateway
                lambda1
                lambda2
                lambda3
                rds
            }
        }

        styles {
            element "Container" {
                background #ffffff
            }
            element "API Gateway" {
                icon "https://static.structurizr.com/icons/aws/api-gateway.png"
            }
            element "Lambda" {
                icon "https://static.structurizr.com/icons/aws/lambda.png"
            }
            element "Database" {
                shape cylinder
                icon "https://static.structurizr.com/icons/aws/rds.png"
            }
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            deploymentNode "Amazon Web Services - VPC" {
                icon "https://static.structurizr.com/icons/aws/vpc.png"
            }
            deploymentNode "Amazon Web Services - Subnet" {
                icon "https://static.structurizr.com/icons/aws/subnet.png"
            }
        }

        themes https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
    }

}
