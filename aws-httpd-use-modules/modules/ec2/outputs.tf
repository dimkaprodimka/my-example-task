output "ec2_ami" {
  value = data.aws_ami.latest_amazon_linux.id
}

output "ec2_public_ip" {
  value = aws_instance.my_Amazon_Linux[*].public_ip
}

output "ec2_type" {
  value = aws_instance.my_Amazon_Linux[*].instance_type
}
