provider "aws" {
  region = "us-west-2"
}
resource "aws_instance" "jenkins" {
  ami           = "ami-03c983f9003cb9cd1"
  instance_type = "t2.micro"
  subnet_id = "subnet-0727683767e471d05"
  vpc_security_group_ids = ["sg-018477df61c11f0f8"]
  key_name = "yadhu devops"
  tags = {
    Name = "yadhu-jenkins"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }
  provisioner "file" {
    source = "jenkins.sh"
    destination = "/home/ubuntu/jenkins.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod a+x /home/ubuntu/jenkins.sh",
      "sudo /home/ubuntu/jenkins.sh"
    ]
  }
}
output "ip" {
  value = aws_instance.jenkins.public_ip
}