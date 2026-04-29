# terraform_example/test02_basic/variable02/main.py

# 여러 개의 type을 map에 담고 싶으면 object type을 사용하면 된다.
variable "member1" {
    # number, string, bool type을 담을 수 있는 object type 선언
    type = object({
        num = number
        name = string
        is_man = bool
    })
    # 설명
    description = "회원 한 명의 정보입니다"
    # default 값 대입
    default = {
        num = 1
        name = "kim"
        is_man = true
    }
}

variable "bucket_config" {
    type = object({
        # 반드시 넣어야 하는 값
        name = string
        # 안 넣어도 되는 값(optional)(type, default 값)
        region = optional(string, "ap-northeast-2")
        # optional하면서 bool type이고 넣지 않으면 false로 설정된다.
        versioning = optional(bool, false)
    })
    description = "bucket 기본 설정값입니다"

    default = {
        name = "나의 기본 s3 bucket입니다"
        # region과 versioning은 생략했으므로 위에서 정의한 optional 기본값이 설정됩니다.
    }
}

# 위에서 선언한 member1, bucket_config object 안에 저장된 내용을 output을 통하여 이쁘게 출력해보세요

output "member1_num" {
    value = "member1 번호: ${var.member1.num}"
}

output "member1_name" {
    value = "member1 이름: ${var.member1.name}"
}

output "member1_is_man" {
    value = "member1 성별: ${var.member1.is_man}"
}

output "bucket_config_name" {
    # map에 저장된 데이터 참조법 .key
    value = "버킷 이름은 ${var.bucket_config.name}"
}

output "bucket_region" {
    # map에 저장된 데이터 참조법 .key
    value = "버킷 리전은 ${var.bucket_config.region}"
}

output "bucket_versioning" {
    # map에 저장된 데이터 참조법 .key
    value = "버킷 버전은 ${var.bucket_config.versioning}"
}