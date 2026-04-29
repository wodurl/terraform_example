# terraform_example/hello/main.tf
# tf 파일은 HCL 형식의 파일

# 테라폼과 aws 버전에 관한 정보를 명시해놓는 것이 좋다
terraform {
    required_version = "~>1.14.0" # ~> 1.14.0 이거는 1.14.까지는 고정하겠따!
    # terraform 1.15에서 실행되어 에러나는 것을 방지
    required_providers {
        aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
        }
    }
}

provider "aws"{
    region = "ap-northeast-2"
}

# 밥먹듯이 쌉 간단한 VPC 하나 생성
resource "aws_vpc" "test_vpc" {
    cidr_block = "10.0.1.0/24"
    enable_dns_hostnames = true # 인스턴스에 dns 이름을 부여하기 위해 활성화
    enable_dns_support = true
    tags = {
        Name = "terraform_test_vpc"
    }
}

# internet gateway
resource "aws_internet_gateway" "igw"{
    # 어떤 VPC에 붙여야 하지? 선택에 대한 문제가 발생
    vpc_id = aws_vpc.test_vpc.id
    tags = {
        Name = "test_vpc_igw" # tags에 들어가는 이름은 마음대로 지을 수 있다. aws colsole에 로그인하면 보인다.
    }
}