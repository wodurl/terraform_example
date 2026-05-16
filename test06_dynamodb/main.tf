# ~/terraform_example/test06_dynamo_DB/main.tf
terraform {
    required_version = ">=1.14.0" # github action에서 에러 나지 않게 일부 수정
    # terraform 1.15에서 실행되어 에러나는 것을 방지
    required_providers {
        aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
        }
    }
}

resource "aws_dynamodb_table" "members" {
    name = "members" # 테이블 명은 마음대로 지을 수 있다
    billing_mode = "PAY_PER_REQUEST" # 비용 지불 방식 (요청 갯수 당 과금하겠다)
    # partition key
    hash_key = "num" # 카테고리명은 마음대로 지을 수 있다 (RDBMS의 PK와 유사)
    # 정렬이 필요하다면 sort key도 추가한다. 밑에서 attribute도 추가해야 한다
    # range_key = "정렬의 기준이 되는 칼럼"

    attribute {
        name = "num"
        type = "N"  # 카테고리의 데이터 타입. S는 문자열, N은 숫자
    }
    tags = {
        Name = "members TABLE"
    }
}