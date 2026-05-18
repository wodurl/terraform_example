# terraform_example/test08_autoscale/variables.tf

# 변수 정의 
variable "region" { default = "ap-northeast-2" }
variable "instance_type" { default = "t3.micro" }

# autoscaling group에서 원하는 ec2의 개수 
variable "desired_capacity" { default = 2 }

# autoscaling group에서 최소 ec2의 개수 
variable "min_size" { default = 1 }

# autoscaling group에서 초대 ec2의 개수 
variable "max_size" { default = 5 }

variable "avail_zone_1" { default = "ap-northeast-2a" } # 첫번째 가용영역
variable "avail_zone_2" { default = "ap-northeast-2c" } # 두번째 가용영역

# ec2의 갯수
variable "ec2_count" { default = 3 }

# variables.tf에 domain name 변수 추가
variable "domain_name" {
    default = "wodurl.shop"
}