data "aws_ecr_repository" "mis" {
  provider = aws.ecr-region
  name     = "${var.client}-mis"
}

resource "aws_ecs_service" "mis" {
  cluster    = aws_ecs_cluster.this.id
  depends_on = [aws_lb.web]

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = 1
  enable_ecs_managed_tags            = "false"
  health_check_grace_period_seconds  = "900"
  launch_type                        = "FARGATE"

  load_balancer {
    container_name   = "${var.client}-${var.environment}-mis"
    container_port   = var.mis_port
    target_group_arn = aws_lb_target_group.mis.arn
  }

  name = "${var.client}-${var.environment}-mis"

  network_configuration {
    assign_public_ip = "true"

    security_groups = [var.security_group_ecs]
    subnets         = var.subnets_web
  }

  platform_version    = var.ecs_platform_version
  scheduling_strategy = "REPLICA"
  task_definition     = aws_ecs_task_definition.mis.arn

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

}

resource "aws_ecs_task_definition" "mis" {
  container_definitions    = <<-EOF
[
   {
      "name":"${var.client}-${var.environment}-mis",
      "entryPoint":[],
      "environment":[],
      "essential":true,
      "image":"${data.aws_ecr_repository.mis.repository_url}:latest",
      "links":[],
      "logConfiguration":{
         "logDriver":"awslogs",
         "options":{
            "awslogs-group":"/ecs/${var.client}-${var.environment}",
            "awslogs-region":"${var.region}",
            "awslogs-stream-prefix":"ecs"
         }
      },
      "mountPoints":[],
      "portMappings":[
         {
            "containerPort":${var.mis_port},
            "hostPort":${var.mis_port},
            "protocol":"tcp"
         }

      ],
      "volumesFrom":[]
   }
]
EOF
  cpu                      = var.task_cpu_limit
  execution_role_arn       = aws_iam_role.ecs-execution.arn
  family                   = "${var.client}-${var.environment}-mis"
  memory                   = var.task_memory_limit
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE", "EC2"]
  task_role_arn            = aws_iam_role.ecs-task.arn
  tags = {
    Name = "${var.client}-${var.environment}-mis-task"
  }
}

# Load Balancer

resource "aws_lb_target_group" "mis" {
  deregistration_delay = var.tg_deregistration_delay

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "60"
    matcher             = "200"
    path                = "/mis/login"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "4"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "${var.client}-${var.environment}-mis-tg"
  port                          = var.mis_port
  protocol                      = "HTTP"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "ip"
  vpc_id      = var.vpc_id
}
