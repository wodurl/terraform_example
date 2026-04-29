# test02_basic/file3/main.tf

variable "info" {
    description = "한 사람의 정보입니다"
    default = {
        num = 1
        name = "kim"
        body = {
            height = 172
            weight = 68
            blood = "O type"
        }
        hobby = ["programming", "piano", "movie"]
    }
}

output "debug01" {
    # yamlencode() 함수를 이용하면 map에 들어있는 데이터를 참조해서 yml 문서를 만들어낼 수 있다.
    # ansible에서 사용하는 inventory 파일을 yml 형식으로도 정의할 수 있는데
    # 이걸 이용해서 map에 있는 정보를 바탕으로 ansible에 사용가능한 inventory 파일을 만들어낸다.
    value = yamlencode({info = var.info})
}

variable "ec2_ip" {
    description = "가상의 ec2 public ip"
    default = "111.111.222.222"
}

# inventory 파일 생성 resource
resource "local_file" "ansible_inventory" {
    # 생성할 파일의 경로와 경로명
    filename = "${path.module}/inventory.yml"
    # 파일의 내용
    # map 안의 map, map 안의 list 등의 구조에 익숙해져야 한다
    content = yamlencode({
        all = {
            hosts = {
                "${var.ec2_ip}" = {
                    ansible_user                    = "ec2-user"
                    ansible_ssh_private_key_file    = "${path.module}/lecture-key.pem"
                }
            }
        }
    })
}