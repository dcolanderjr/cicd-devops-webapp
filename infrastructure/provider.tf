provider "aws" {
  region = "ca-central-1"
}

module "jenkins-agent" {
  source = "./compute/jenkins-agent"
}

module "jenkins-master" {
  source = "./compute/jenkins-master"
}

module "sns" {
  source = "./sns"
} 

module "lambda" {
  source = "./compute/lambda"
}

module "promehteus" {
  source = "./compute/prometheus"
}

module "sonarqube" {
  source = "./compute/sonarqube"
}
module "eventbridge" {
  source = "./eventbridge"
}