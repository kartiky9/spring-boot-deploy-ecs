environment = "dev"

vpc_cidr = "10.0.0.0/16"

subnet_web_public = ["10.0.32.0/24", "10.0.33.0/24"]
subnet_db_private = ["10.0.48.0/24", "10.0.49.0/24"]

multi_az                = false
backup_retention_period = 3

ec2_key_name = "spring-dev-stage"
