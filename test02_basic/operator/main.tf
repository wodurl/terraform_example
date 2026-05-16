# operator/main.tf

variable "env" {
    default = "dev"
}

locals {
    # dev 환경이면 최소 사양의 ec2, prod 환경이면 좋은 사양의 ec2를 만들기 위한 로직
    instance_type = var.env == "dev" ? "t3.micro" : "t2.large"
}

output "debug" {
    value = "instance type은 ${local.instance_type}입니다"
}