provider "aws" {
  region = var.region
}

module "example" {
  source = "../.."

  create_sns_topic = var.create_sns_topic

  context = module.this.context
}
