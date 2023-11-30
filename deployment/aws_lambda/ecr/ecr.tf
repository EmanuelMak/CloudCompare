# ecr.tf

resource "aws_ecr_repository" "camelcase_lambda_repo" {
  name = "camelcase-lambda-repo"
}

resource "aws_ecr_repository" "checkprime_lambda_repo" {
  name = "checkprime-lambda-repo"
}

resource "aws_ecr_repository" "create_table_lambda_repo" {
  name = "create-table-lambda-repo"
}

output "camelcase_lambda_repo_uri" {
  value = aws_ecr_repository.camelcase_lambda_repo.repository_url
}

output "checkprime_lambda_repo_uri" {
  value = aws_ecr_repository.checkprime_lambda_repo.repository_url
}

output "create_table_lambda_repo_uri" {
  value = aws_ecr_repository.create_table_lambda_repo.repository_url
}
