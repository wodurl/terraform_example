# test02_basic/fiel02/main.tf

# local_file을 이용해서 ansible.cfg를 만들어보자
resource "local_file" "ansible_config" {
    filename = "${path.module}/ansible.cfg"
    # 파일의 내용
    content = <<-EOF
        [defaults]
        # 인벤토리 파일의 위치(yml 파일로 만들 예정)
        inventory = ./inventory.yml
        # 새로운 서버 접속 시 yes/no 확인 과정 생략(자동화의 필수)
        host_key_checking = False
    EOF
}

# 결과 확인용 메세지
output "debug" {
    value = "ansible 설정 파일 ${local_file.ansible_config.filename} 생성이 완료되었습니다."
}