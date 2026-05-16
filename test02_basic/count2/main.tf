# test02_basic/count2/main.tf

locals {
    student_list = ["kim", "lee"]
}

resource "local_file" "students_notes" {
    # list의 요소 갯수처럼 만들기 -> length() 함수를 이용하면 list의 size를 알 수가 있다.
    count = length(local.student_list)
    filename = "${path.module}/student_${local.student_list[count.index]}.txt"
    content = "안녕하세요 ${local.student_list[count.index]} 학생의 실습 노트입니다"
}

output "debug" {
    value = local_file.students_notes[*].filename
}