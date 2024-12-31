# output file

output "dev_pub_ec2_pub_ip" {
  value = aws_instance.tf_pub_ec2.public_ip
  sensitive = true # Will not print output in the terminal
}

output "dev_pvt_ec2_pvt_ip" {
  value = aws_instance.tf_pvt_ec2.private_ip
}