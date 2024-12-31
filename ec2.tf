# Launch EC2 in public subnet
resource "aws_instance" "tf_pub_ec2" {
  ami = var.var_ami
  instance_type = var.var_instance_type
  key_name = var.var_key_name
  subnet_id = aws_subnet.dev_pub_sub.id
  vpc_security_group_ids = [aws_security_group.dev_vpc_sg_allow_ssh.id]
  
  associate_public_ip_address = true # Associate public IP
 
  tags = {
    Name = "tf_pub_ec2"
  }
}
# Launch EC2 in private subnet, no need to give public IP

resource "aws_instance" "tf_pvt_ec2" {
  ami = var.var_ami
  instance_type = var.var_instance_type
  key_name = var.var_key_name
  subnet_id = aws_subnet.dev_pvt_sub.id
  vpc_security_group_ids = [aws_security_group.dev_vpc_sg_allow_ssh.id]
  tags = {
    Name = "tf_pvt_ec2"
  }
}
