# module "sg" {
#   source = "./sg_module"
# }

resource "aws_instance" "test_instance" {
  instance_type = "t2.micro"
  ami = "ami-0257068e70c26c2bc"
  vpc_security_group_ids = [ aws_security_group.atomicoconut_security_group.id ]
}

output "test_instance_id" {
  value = aws_instance.test_instance.id
}
