variable "var_ami" {
  description = "passing AMI values to ec2.tf"
  type = string
  default = ""
}

variable "var_instance_type" {
    type = string
    default = ""
}

variable "var_key_name" {
  type = string
  default = ""
}