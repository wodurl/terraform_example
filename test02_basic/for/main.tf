# terraform_example/test02_basic/for/main.tf

variable "user_list" {
    type = list(string)
    default = [ "alice", "bob","david","scott","json" ]
}

output "debug01_user_list" {
    # 배열에 저장된 item을 그대로 출력
    value = [for item in var.user_list : item]
}

output "debug01_user_list2" {
    # 배열에 저장된 item을 대문자로 변환해 출력
    value = [for item in var.user_list : upper(item)]
}

output "debug01_user_list3" {
    # 배열에 저장된 item의 길이가 4보다 작은 값만 출려
    value = [for item in var.user_list : item if length(item) <= 4]
}

# 결과 데이터를 map 형태로 얻어내기
output "debug01_user_list4" {
    # { 키 => 값 } 형태로 결과가 나오며, 중괄호 {}를 사용합니다.
    value = {for name in var.user_list : name => "IAM-USER-${name}"}
}

# 반복문 돌면서 index 값도 활용해보기
output "debug05_user_list" {
    # for 인덱스,값
    value = [ for index, item in var.user_list : "${index+1}번째 사용자: ${item}"]
}

# 복합 활용
output "debug06_user_list6" {
    # 인덱스를 key 값, item을 value 값으로 가지는 map 만들기
    # 인덱스가 문자열로 변환되어서 key 값으로 지정된다.
    value = { for index, item in var.user_list : index => item }
}

# 여러 줄의 문자열을 편하게 구성하기
output "debug07_multiline" {
    # <<- 기호를 쓰면 좌측의 공백이 알아서 제거가 된다
    # EOF는 마음대로 정할 수 있다. 끝날 때만 동일한 문자열로 끝내면 된다.
    value = <<-EOF
        #!/bin/bash
        dnf update -y
        dnf install -y nginx
        systemctl enable nginx
        systemctl start nginx
    EOF
}