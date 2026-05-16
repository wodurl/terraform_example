# terraform_example/test01/main.tf

# version 명시하기
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

# 1. provider 설정
provider "aws" {
    region = "ap-northeast-2" # 서울 리전
}

# 2. vpc 및 네트워크 생성(인프라 기초 공사)
resource "aws_vpc" "main"{
    cidr_block                  = "10.0.0.0/16"
    enable_dns_hostnames        = true
    tags                        = { Name = "lecture-vpc" }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "igw" {
    # 위에서 만들어진 VPC의 ID를 참조하도록 한다.
    vpc_id                      = aws_vpc.main.id
    tags                        = { Name = "lecture-igw"}
}

# 현재 리전에서 사용 가능한(available) 가용 영역 데이터 가져오기
# 리소스를 생성하는 게 아니라 “정보 조회”
data "aws_availability_zones" "available"{
    state = "available"
}

# public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id                      = aws_vpc.main.id
    cidr_block                  = "10.0.1.0/24" # 256개의 ip를 이 방에 할당
    # data.aws_availability_zones.available.names는 배열인데 거기에는 여러 개의 가용 영역 데이터가 들어있다.
    # 그 중에서 0번 방에 들어있는 데이터를 연결한다
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch     = true
    tags                        = { Name = "lecture_subnet" }
}

# 라우팅 테이블 : 트래픽 이정표
resource "aws_route_table" "public_rt" {
    # 어떤 vpc의 소속인지 설정
    vpc_id                      = aws_vpc.main.id
    # 라우팅 규칙(0.0.0.0/0)으로 가는 트래픽은 인터넷 게이트웨이(igw)로 보내라
    route {
        cidr_block              = "0.0.0.0/0"
        gateway_id              = aws_internet_gateway.igw.id
    }
}

# public subnet 을 위의 라우팅 테이블로 연결
resource  "aws_route_table_association" "a" {
    subnet_id                   = aws_subnet.public_subnet.id # 우리가 만든 퍼블릭 서브넷은
    route_table_id              = aws_route_table.public_rt.id # 위에서 만든 라우팅 테이블로 연결
}

# pem 파일 관련 작업

# 알고리즘 결정
resource "tls_private_key" "pk" {
  algorithm                     = "RSA"
  rsa_bits                      = 4096
}

# 키 등록
resource "aws_key_pair" "kp" {
  key_name                      = "lecture-key"
  public_key                    = tls_private_key.pk.public_key_openssh
}

# 개인 키를 가져오기
resource "local_file" "ssh_key" {
    # ${path.module}은 실행 경로를 의미한다
  filename                      = "${path.module}/lecture-key.pem"
  content                       = tls_private_key.pk.private_key_pem
  file_permission               = "0600"
}

# 0427
# 보안 그룹
resource "aws_security_group" "ssh_sg" {
    # 보안 그룹의 이름은 겹치지 않게 유일하게 식별되는 이름으로 지어야 한다
    name                        = "allow-ssh"
    vpc_id                      = aws_vpc.main.id

    # 밖에서 안으로 들어오는 규칙 ingress
    ingress {
        from_port   = 22 # 시작 port
        to_port     = 22 # 끝 port
        protocol    = "tcp" # protocol
        cidr_blocks = ["0.0.0.0/0"] # 외부에서 들어오는 모든 traffic (실무에서는 내 ip만)
    }
    # 밖에서 안으로 들어오는 규칙 ingress
    ingress {
        from_port   = 80 # 시작 port
        to_port     = 80 # 끝 port
        protocol    = "tcp" # protocol
        cidr_blocks = ["0.0.0.0/0"] # 외부에서 들어오는 모든 traffic (실무에서는 내 ip만)
    }
    # 안에서 밖으로 나가는 규칙 egress
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1" # 모든 프로토콜
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# ec2에 설치할 amazon linux 최신 이미지 검색
data "aws_ami" "latest_al2023" {
    most_recent     = true
    owners          = ["amazon"]
    filter {
        name        = "name"
        values      = ["al2023-ami-*-x86_64"] # 이름이 이렇게 시작하는 것들 중에서 최신 이미지 검색
    }
}

# ec2 만들기
resource "aws_instance" "my_ec2" {
    # ec2 instance 3개 만들기
    count                   = 3
    ami                     = data.aws_ami.latest_al2023.id # 검색된 최신의 os 이미지 id
    instance_type           = "t3.micro"                    # 서버 사양
    subnet_id               = aws_subnet.public_subnet.id   # 위에서 미리 준비한 public subnet의 id
    vpc_security_group_ids  = [aws_security_group.ssh_sg.id]   # 보안 그룹(여러개 등록할 수 있다)
    key_name                = aws_key_pair.kp.key_name      # 위에서 미리 준비한 key pair의 이름
    tags = {
        Name = "my-ec2-${count.index + 1}"
    }
}

# 생성된 ec2의 public IP를 출력
output "instance_public_ip" {
    description = "만들어진 ec2의 public IPv4 주소"
    # .public_ip하면 참조가 가능하다
    # * 연산자를 이용해서 모든 public ip를 배열에 담아오기
    value = aws_instance.my_ec2[*].public_ip
}

# public ip를 이용해서 inventory.yml 파일 만들기
resource "local_file" "ansible_inventory" {
    # 파일의 경로와 파일명
    filename = "${path.module}/inventory.yml"
    # 파일의 내용을 map 객체를 이용해서 구성하기
    content = yamlencode({
        all = {
            hosts = {
                # 반복문을 이용해서 모든 hosts(3개)의 정보를 추가한다
                for instance in aws_instance.my_ec2 : 
                # string type key => map type value
                instance.public_ip => {
                    ansible_user = "ec2-user"
                    ansible_ssh_private_key_file = "${path.module}/lecture-key.pem"
                }
            }
        }
    })
}

# ansible.cfg 파ㅓ일 생성
resource "local_file" "ansible_config" {
    filename = "${path.module}/ansible.cfg"
    # inventory 파일의 경로와 ssh 보안 확인(Host key Checking)을 자동으로 생성
    content = <<-EOF
        [defaults]
        inventory = ./inventory.yml
        host_key_checking = False
    EOF
}

# 1. 인프라 생성 후 ansible playbook을 실행 가능한 시간만큼 대기한다.
resource "terraform_data" "wait_for_instance" {
    # 서버, 인벤토리, 설정 파일이 모두 준비된 이후에 이 블럭이 실행되도록 순서 보장
    depends_on = [ aws_instance.my_ec2, local_file.ansible_inventory, local_file.ansible_config ]

    # ec2 인스턴스의 id가 변경된다면 다시 실행하도록 트리거를 설치한다
    # 즉 ec2가 새롭게 만들어지면 이 블럭이 다시 실행되고 결과적으로 sleep 30이 다시 실행된다.
    # triggers_replace = 이 값이 바뀌면 이 리소스를 강제로 다시 실행(재생성)해라
    # 1개가 아니면 배열로 전달할 수 있다
    triggers_replace = aws_instance.my_ec2[*].id

    # local computer(rocky linux)에서 실행할 명령
    # 아래의 작업이 성공한 기억이 있으면 다시 또 실행되지 않는다.
    provisioner "local-exec" {
        command = "sleep 30"
    }
}

# 2. ansible playbook 실행
resource "terraform_data" "ansible_run" {
    # 실행 순서 보장
    depends_on = [ terraform_data.wait_for_instance ]

    # ec2 인스턴스의 id가 변경된다면 다시 실행하도록 트리거를 설치한다
    # 즉 ec2가 새롭게 만들어지면 이 블럭이 다시 실행되고 결과적으로 sleep 30이 다시 실행된다.
    # triggers_replace = 이 값이 바뀌면 이 리소스를 강제로 다시 실행(재생성)해라
    triggers_replace = aws_instance.my_ec2[*].id

    # 아래의 작업이 성공한 기억이 있으면 다시 또 실행되지 않는다.
    provisioner "local-exec" {
        command = "ansible-playbook site.yml"
    }
}