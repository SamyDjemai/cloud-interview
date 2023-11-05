resource "aws_dynamodb_table" "this" {
  name           = "samyd-ornikar-terraform-state-lock-${var.environment}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }
}
