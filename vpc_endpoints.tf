#
# in each "target" VPC
#
resource "aws_subnet" "target_nlb" {
  count = local.target_count

  vpc_id            = aws_vpc.target[count.index].id
  cidr_block        = local.vpc_endpoints_cidr
  availability_zone = local.vpc_endpoint_supported_az

  tags = {
    "Name" = "target-nlb-${count.index}"
  }
}

# we expose the target machine using an internal NLB
resource "aws_lb" "target" {
  count = local.target_count

  name                             = "target-${count.index}"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = [aws_subnet.target_nlb[count.index].id, aws_subnet.target[count.index].id]
  enable_cross_zone_load_balancing = true
}

# we allow SSH 
resource "aws_lb_target_group" "target" {
  count = local.target_count

  port     = local.ssh_port
  protocol = "TCP"
  vpc_id   = aws_vpc.target[count.index].id
}

resource "aws_lb_target_group_attachment" "target" {
  count = local.target_count

  target_group_arn = aws_lb_target_group.target[count.index].arn
  target_id        = aws_instance.target[count.index].id
  port             = local.ssh_port
}

resource "aws_lb_listener" "target" {
  count = local.target_count

  load_balancer_arn = aws_lb.target[count.index].arn
  port              = local.ssh_port
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.target[count.index].arn
    type             = "forward"
  }
}




#
# in the monitoring VPC :
#
resource "aws_subnet" "monitoring_vpc_endpoints" {
  vpc_id            = aws_vpc.monitoring.id
  cidr_block        = local.vpc_endpoints_cidr
  availability_zone = local.vpc_endpoint_supported_az

  tags = {
    "Name" = "monitoring-vpc-endpoints"
  }
}

# we create endpoint_service pointing at each target NLB
resource "aws_vpc_endpoint_service" "target" {
  count = local.target_count

  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.target[count.index].arn]
  private_dns_name           = "target-${count.index}"

  tags = {
    "Name" = "target-${count.index}"
  }
}

# create an endpoint that will allow us to reach 
# the resource pointed by the vpc_endpoint_service
resource "aws_vpc_endpoint" "target" {
  count = local.target_count

  vpc_id             = aws_vpc.monitoring.id
  subnet_ids         = [aws_subnet.monitoring_vpc_endpoints.id]
  service_name       = aws_vpc_endpoint_service.target[count.index].service_name
  vpc_endpoint_type  = aws_vpc_endpoint_service.target[count.index].service_type
  security_group_ids = [aws_security_group.monitoring.id]

  tags = {
    "Name" = "target-${count.index}"
  }
}

