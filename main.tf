provider "aws" {
  region = "us-east-1"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "medusa" {
  name = "medusa-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "medusa-task"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = aws_iam_role.ecs_execution.arn
  container_definitions   = file("${path.module}/task-def.json")
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [
      "subnet-01076cd45207ab28c",
      "subnet-047fafb6ae5403c31"
    ]
    assign_public_ip = true
    security_groups  = [
      "sg-0e70cb73ad7964474"
    ]
  }
}


