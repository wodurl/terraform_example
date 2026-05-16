# locals/main.tf

# 변수에 들어있는 값을 활용해서 무언가 계산된(조작된) 내부 전용 지역변수 만들어서 값 대입하기

locals {
    resource_name = "${var.project_name}-${var.env}-file"
}

resource "local_file" "example" {
    filename = "${path.module}/${local.resource_name}"
    content = "현재 환경은 ${var.env}입니다"
}