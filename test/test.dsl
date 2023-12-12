workspace {

  model {
    user = person "User" "Uses the application."

    apiGateway = softwareSystem "API Gateway" "Routes incoming API requests to the appropriate Lambda functions."

    camelCaseLambda = softwareSystem "CamelCase Lambda" "Processes requests for camel-casing text."
    checkPrimeLambda = softwareSystem "CheckPrime Lambda" "Handles requests for checking prime numbers and interacts with the database."
    createTableLambda = softwareSystem "CreateTable Lambda" "Responsible for setting up and managing the database schema."

    database = softwareSystem "RDS Database" "Stores and retrieves prime numbers for the CheckPrime Lambda function."

    user -> apiGateway "Sends requests to"
    apiGateway -> camelCaseLambda "Routes requests to /camelcase"
    apiGateway -> checkPrimeLambda "Routes requests to /checkprime"
    checkPrimeLambda -> database "Reads from and writes to"
    createTableLambda -> database "Creates and manages tables"
  }

  views {
    systemContext apiGateway {
      include *
      autoLayout lr
    }

    styles {
      element "Software System" {
        background #1168bd
        color #ffffff
      }
      element "Person" {
        shape person
        background #08427b
        color #ffffff
      }
    }
  }
}