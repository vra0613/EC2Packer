variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "source_ami" {
  type    = string
  default = "ami-0134dde2b68fe1b07"
}