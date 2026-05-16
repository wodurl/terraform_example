# locals2/prod.tfvars

# 파일명이 terraform.tfvars가 아니기 때문에 terraform을 실행할 때 default로 읽어들이진 않는다.
# prod는 production -> 실제 배포용
# plan이나 apply할 때 -var-file="prod.tfvars" 옵션을 주어 실행한다

env = "prod"
project_name = "KTCLOUD-v1"