data "aws_ecr_repository" "app" {
  provider = aws.ecr-region
  name     = var.client
}

data "terraform_remote_state" "spring-common" {
  backend = "s3"

  config = {
    bucket = "spring-tfstate"
    key    = "terraform.tfstate/common-ap-south-1"
    region = var.region
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.client}-${var.environment}-cluster"
  tags = {
    Name = "${var.client}-${var.environment}-cluster"
  }
}

resource "aws_ecs_service" "app" {
  count = var.clojure_socket_server == "" ? 1 : 0

  cluster = aws_ecs_cluster.this.id

  depends_on = [aws_lb.web]

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = var.tasks_count
  enable_ecs_managed_tags            = "false"
  health_check_grace_period_seconds  = "900"
  launch_type                        = "FARGATE"

  load_balancer {
    container_name   = "${var.client}-${var.environment}-backend"
    container_port   = var.server_port
    target_group_arn = aws_lb_target_group.web_app.arn
  }

  name = "${var.client}-${var.environment}-backend"

  network_configuration {
    assign_public_ip = "true"

    security_groups = [var.security_group_ecs]
    subnets         = var.subnets_web
  }

  platform_version    = var.ecs_platform_version
  scheduling_strategy = "REPLICA"
  task_definition     = aws_ecs_task_definition.app.arn

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

}

resource "aws_ecs_service" "with_repl" {
  count = var.clojure_socket_server == "" ? 0 : 1

  cluster = aws_ecs_cluster.this.id

  depends_on = [aws_lb.web, aws_lb.repl[0]]

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = var.tasks_count
  enable_ecs_managed_tags            = "false"
  health_check_grace_period_seconds  = "900"
  launch_type                        = "FARGATE"

  load_balancer {
    container_name   = "${var.client}-${var.environment}-backend"
    container_port   = var.server_port
    target_group_arn = aws_lb_target_group.web_app.arn
  }

  load_balancer {
    container_name   = "${var.client}-${var.environment}-backend"
    container_port   = var.repl_port
    target_group_arn = aws_lb_target_group.repl[0].arn
  }

  name = "${var.client}-${var.environment}-backend"

  network_configuration {
    assign_public_ip = length(var.subnets_nat_public) > 0 ? "false" : "true"

    security_groups = [var.security_group_ecs]
    subnets         = length(var.subnets_nat_public) > 0 ? var.subnets_db : var.subnets_web
  }

  platform_version    = var.ecs_platform_version
  scheduling_strategy = "REPLICA"
  task_definition     = aws_ecs_task_definition.app.arn

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

}

resource "aws_ecs_task_definition" "app" {
  container_definitions    = <<-EOF
[
   {
      "name":"${var.client}-${var.environment}-backend",
      "command":[],
      "entryPoint":[],
      "environment":[
         {
            "name":"SERVER_ENV",
            "value":"${var.environment}"
         },
         {
            "name":"PROFILE",
            "value":"${var.client}-${var.environment}"
         },
         {
            "name":"DB_HOST",
            "value":"${var.db_url}"
         },
         {
            "name":"DB_PORT",
            "value":"${var.db_port}"
         },
         {
            "name":"COGNITO_REGION",
            "value":"${var.cognito_region}"
         },
         {
            "name":"COGNITO_USER_POOL_ID",
            "value":"${var.cognito_user_pool_id}"
         },
         {
            "name":"COGNITO_USER_POOL_CLIENT_ID",
            "value":"${var.cognito_user_pool_client_id}"
         },
         {
            "name":"PUBLIC_S3_BUCKET_NAME",
            "value":"${var.public_s3_bucket_name}"
         },
         {
            "name":"PRIVATE_S3_BUCKET_NAME",
            "value":"${var.private_docs_s3_bucket_name}"
         },
         {
            "name":"PUBLIC_S3_CUSTOM_DOMAIN",
            "value":"${var.public_s3_custom_domain}"
         }
      ],
      "secrets":[
         {
            "name":"DB_NAME",
            "valueFrom":"${var.secrets_arn}:DB_NAME::"
         },
         {
            "name":"DB_USER",
            "valueFrom":"${var.secrets_arn}:DB_USER::"
         },
         {
            "name":"DB_PASS",
            "valueFrom":"${var.secrets_arn}:DB_PASS::"
         },
         {
            "name":"ANALYTICS_CLIENT_ID",
            "valueFrom":"${var.secrets_arn}:ANALYTICS_CLIENT_ID::"
         },
         {
            "name":"ANALYTICS_CLIENT_SECRET",
            "valueFrom":"${var.secrets_arn}:ANALYTICS_CLIENT_SECRET::"
          },
          {
            "name":"ANALYTICS_WEBHOOKS_API_KEY",
            "valueFrom":"${var.secrets_arn}:ANALYTICS_WEBHOOKS_API_KEY::"
          },
          {
            "name":"KEYSTORE_PASS",
            "valueFrom":"${var.secrets_arn}:KEYSTORE_PASS::"
         },
         {
            "name":"BASIC_AUTH_PASSWORDS",
            "valueFrom":"${var.secrets_arn}:BASIC_AUTH_PASSWORDS::"
         },
         {
            "name":"DECENTRO_CLIENT_ID",
            "valueFrom":"${var.secrets_arn}:DECENTRO_CLIENT_ID::"
         },
         {
            "name":"DECENTRO_CLIENT_SECRET",
            "valueFrom":"${var.secrets_arn}:DECENTRO_CLIENT_SECRET::"
         },
         {
            "name":"DECENTRO_ACCOUNTS_MODULE_SECRET",
            "valueFrom":"${var.secrets_arn}:DECENTRO_ACCOUNTS_MODULE_SECRET::"
         },
         {
            "name":"DECENTRO_KYC_MODULE_SECRET",
            "valueFrom":"${var.secrets_arn}:DECENTRO_KYC_MODULE_SECRET::"
         },
         {
            "name":"DECENTRO_PREPAID_MODULE_SECRET",
            "valueFrom":"${var.secrets_arn}:DECENTRO_PREPAID_MODULE_SECRET::"
         },
         {
            "name":"DECENTRO_YES_PROVIDER_SECRET",
            "valueFrom":"${var.secrets_arn}:DECENTRO_YES_PROVIDER_SECRET::"
         },
         {
            "name":"DECENTRO_LIVQUIK_PROVIDER_SECRET",
            "valueFrom":"${var.secrets_arn}:DECENTRO_LIVQUIK_PROVIDER_SECRET::"
         },
         {
            "name":"DECENTRO_PAYMENTS_MODULE_SECRET",
            "valueFrom":"${var.secrets_arn}:DECENTRO_PAYMENTS_MODULE_SECRET::"
         },
         {
            "name":"DECENTRO_PAYMENTS_PROVIDER_SECRET",
            "valueFrom":"${var.secrets_arn}:DECENTRO_PAYMENTS_PROVIDER_SECRET::"
         },
         {
            "name":"ACCOUNT_METADATA_CRYPTO_KEY",
            "valueFrom":"${var.secrets_arn}:ACCOUNT_METADATA_CRYPTO_KEY::"
         },
         {
            "name":"DECENTRO_CALLBACK_SECRET",
            "valueFrom":"${var.secrets_arn}:DECENTRO_CALLBACK_SECRET::"
         },
         {
            "name": "DECENTRO_MASTER_VIRTUAL_ACCOUNT",
            "valueFrom":"${var.secrets_arn}:DECENTRO_MASTER_VIRTUAL_ACCOUNT::"
         },
         {
            "name": "DECENTRO_POOL_ACCOUNT",
            "valueFrom":"${var.secrets_arn}:DECENTRO_POOL_ACCOUNT::"
         },
         {
            "name":"FIREBASE_SERVICE_KEY",
            "valueFrom":"${var.secrets_arn}:FIREBASE_SERVICE_KEY::"
         },
         {
            "name":"REWARD_SSO_CRYPTO_KEY",
            "valueFrom":"${var.secrets_arn}:REWARD_SSO_CRYPTO_KEY::"
         },
         {
            "name":"REWARD_SSO_CRYPTO_IV",
            "valueFrom":"${var.secrets_arn}:REWARD_SSO_CRYPTO_IV::"
         },
         {
            "name":"REWARD_CREATEUSER_CRYPTO_KEY",
            "valueFrom":"${var.secrets_arn}:REWARD_CREATEUSER_CRYPTO_KEY::"
         },
         {
            "name":"REWARD_CREATEUSER_CRYPTO_IV",
            "valueFrom":"${var.secrets_arn}:REWARD_CREATEUSER_CRYPTO_IV::"
         },
         {
            "name":"REWARD_CREATEUSER_CLIENT_TOKEN",
            "valueFrom":"${var.secrets_arn}:REWARD_CREATEUSER_CLIENT_TOKEN::"
         },
         {
            "name":"REWARD_CREATEUSER_URL",
            "valueFrom":"${var.secrets_arn}:REWARD_CREATEUSER_URL::"
         }
      ],
      "essential":true,
      "healthCheck":{
         "command":[
            "CMD-SHELL",
            "[ \"$(curl --insecure https://localhost:8443/healthcheck)\" = \"accepted\" ] && exit 0 || exit 1"
         ],
         "interval":30,
         "retries":10,
         "startPeriod":300,
         "timeout":10
      },
      "image":"${data.aws_ecr_repository.app.repository_url}:latest",
      "links":[],
      "logConfiguration":{
         "logDriver":"awslogs",
         "options":{
            "awslogs-group":"/ecs/${var.client}-${var.environment}",
            "awslogs-region":"${var.region}",
            "awslogs-stream-prefix":"ecs"
         }
      },
      "mountPoints":[
        {
          "sourceVolume": "Logdir",
          "containerPath": "/app/logs",
          "readOnly": false
        }
      ],
      "portMappings":[
         {
            "containerPort":${var.repl_port},
            "hostPort":${var.repl_port},
            "protocol":"tcp"
         },
         {
            "containerPort":${var.server_port},
            "hostPort":${var.server_port},
            "protocol":"tcp"
         }

      ],
      "volumesFrom":[]
   },
   {
      "name":"${var.client}-${var.environment}-vector",
      "command":["--config","/app/${var.environment}-vector.yaml"],
      "cpu":64,
      "entryPoint":[],
      "environment":[
         {
            "name":"CONFIG",
            "value":"${var.environment}"
         }
      ],
      "secrets":[
         {
            "name":"LOGTAIL_TOKEN",
            "valueFrom":"${var.secrets_arn}:LOGTAIL_TOKEN::"
         }
      ],
      "essential":true,
      "image":"timberio/vector:${var.vector_image_tag}",
      "links":[],
      "logConfiguration":{
         "logDriver":"awslogs",
         "options":{
            "awslogs-group":"/ecs/${var.client}-${var.environment}",
            "awslogs-region":"${var.region}",
            "awslogs-stream-prefix":"ecs-logs"
         }
      },
      "memory":128,
      "memoryReservation":8,
      "mountPoints":[
        {
          "sourceVolume": "Logdir",
          "containerPath": "/app",
          "readOnly": true
        }
      ],
      "volumesFrom":[]
   }
]
EOF
  cpu                      = var.task_cpu_limit
  execution_role_arn       = aws_iam_role.ecs-execution.arn
  family                   = "${var.client}-${var.environment}-backend"
  memory                   = var.task_memory_limit
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE", "EC2"]
  task_role_arn            = aws_iam_role.ecs-task.arn
  volume {
    name = "Logdir"
  }
  tags = {
    Name = "${var.client}-${var.environment}-ecs-task"
  }
}

resource "aws_cloudwatch_log_group" "ecs-app" {
  name = "/ecs/${var.client}-${var.environment}"
}


## Load balancers

resource "aws_lb" "web" {
  drop_invalid_header_fields = "false"
  enable_deletion_protection = "false"
  enable_http2               = "true"
  idle_timeout               = "180"
  internal                   = "false"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "${var.client}-${var.environment}-web-lb"
  security_groups            = var.security_group_web

  subnets = var.subnets_web
}

resource "aws_lb" "repl" {
  count                            = var.clojure_socket_server == "" ? 0 : 1
  drop_invalid_header_fields       = "false"
  enable_deletion_protection       = "true"
  enable_cross_zone_load_balancing = "true"
  idle_timeout                     = "180"
  internal                         = "true"
  ip_address_type                  = "ipv4"
  load_balancer_type               = "network"
  name                             = "${var.client}-${var.environment}-repl-lb"

  subnets = var.subnets_web
}

resource "aws_lb_target_group" "web_app" {
  deregistration_delay = var.tg_deregistration_delay

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "60"
    matcher             = "200"
    path                = "/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = "5"
    unhealthy_threshold = "4"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "${var.client}-${var.environment}-app-tg"
  port                          = var.server_port
  protocol                      = "HTTPS"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "web_https" {
  certificate_arn = aws_acm_certificate.ecs.arn

  default_action {
    target_group_arn = aws_lb_target_group.web_app.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.web.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
}

resource "aws_lb_listener" "web_HTTP_redirect" {
  default_action {
    order = "1"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_302"
    }

    type = "redirect"
  }

  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_target_group" "repl" {
  count = var.clojure_socket_server == "" ? 0 : 1

  deregistration_delay = var.tg_deregistration_delay

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "30"
    port                = "traffic-port"
    protocol            = "TCP"
    unhealthy_threshold = "2"
  }

  name     = "${var.client}-${var.environment}-repl-tg"
  port     = var.repl_port
  protocol = "TCP"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "source_ip"
  }

  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "repl" {
  count = var.clojure_socket_server == "" ? 0 : 1

  default_action {
    order            = "1"
    target_group_arn = aws_lb_target_group.repl[0].arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.repl[0].arn
  port              = var.repl_port
  protocol          = "TCP"
}


## Auto Scaling
# enabled only when tasks_count == 0

resource "aws_appautoscaling_target" "ecs_target" {
  count = var.repl_tasks_count == 0 ? 1 : 0

  max_capacity       = var.tasks_count_max
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${var.clojure_socket_server == "" ? aws_ecs_service.app[0].name : aws_ecs_service.with_repl[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count = var.repl_tasks_count == 0 ? 1 : 0

  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.autoscaling_cpu_threshold

    scale_in_cooldown  = 300
    scale_out_cooldown = 120
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count = var.repl_tasks_count == 0 ? 1 : 0

  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = var.autoscaling_memory_threshold

    scale_in_cooldown  = 300
    scale_out_cooldown = 120
  }
}

#resource "aws_appautoscaling_policy" "ecs_policy_requests" {
#  count = var.repl_tasks_count == 0 ? 1 : 0
#
#  name               = "requests-autoscaling"
#  policy_type        = "TargetTrackingScaling"
#  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
#  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
#  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace
#
#  target_tracking_scaling_policy_configuration {
#    predefined_metric_specification {
#      predefined_metric_type = "ALBRequestCountPerTarget"
#      resource_label         = "TBD"
#    }
#
#    target_value = var.autoscaling_requests_threshold
#
#    scale_in_cooldown  = 300
#    scale_out_cooldown = 120
#  }
#}
