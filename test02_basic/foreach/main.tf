# test02_basic/foreach/main.tf

# 1. 데이터 정의(학생 명단)
locals {
    students = ["kim", "lee", "park"]
}

# 우리는 set or map에 들어있는 정보를 이용해서 반복문 돌며 여러 개의 자원을 만들어야 할 때가 있다.

# 2. foreach를 사용하여 파일 생성. local_file.student_notes는 map type이다
resource "local_file" "student_notes" {
    # list를 set으로 변환하여 fore_each에 넣어주기
    # for_each에 대입할 수 있는 것은 set or map type만 가능하다(list X)
    # local_file.student_notes는 이제부터 map이다.
    for_each    = toset(local.students)
    # set을 넣어주면 #{each.key}와 #{each.value}가 동일하다
    # map을 넣어주면 #{each.key}와 #{each.value}가 다르다
    filename    = "${path.module}/student_${each.key}.txt"
    content     = "안녕하세요! ${each.value} 학생의 실습 노트입니다"
}

output "debug" {
    description = "생성된 파일들의 전체 경로 목록"
    value = [for item in local_file.student_notes : item.filename]
}