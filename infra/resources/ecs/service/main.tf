resource "aws_ecs_task_definition" "main" {
  family                   = var.task_family_name
  network_mode             = var.network_mode
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = var.requires_compatibilities
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_config.name
      image     = var.container_config.image
      cpu       = var.container_config.cpu
      memory    = var.container_config.memory
      essential = var.container_config.essential
      portMappings = [
        {
          containerPort = var.container_config.container_port
          hostPort      = var.container_config.host_port
        }
      ]
      environment = var.env
      logConfiguration = {
        logDriver = var.log_driver
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.log_region
          awslogs-stream-prefix = var.log_prefix
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.tg_group_id
    container_name   = var.container_config.name
    container_port   = var.container_config.container_port
  }
}
