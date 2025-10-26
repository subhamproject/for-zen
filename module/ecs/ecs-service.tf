# ECS service running the task behind ALB
resource "aws_ecs_service" "this" {
  name            = "nginx-service"
  cluster         = module.ecs_cluster.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = flatten(local.pvt_subnet_id)
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "nginx"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http]
}
