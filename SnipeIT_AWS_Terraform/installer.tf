
//Here we will deploy EC2 on private network segment and attached with existing Security Group.
//After EC2 deploy, we will install Snipe IT docker container and DB Container.

data "aws_security_group" "securitygroup" {
  vpc_id = var.vpc_id

  tags = {
    Name = "snipeit_sggroup" //Using existing Security Group
  }
}

##Start of EC2 RTS
resource "aws_instance" "rts" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = false
  monitoring                  = true
  subnet_id                   = var.private_subnet_az1
  vpc_security_group_ids      = ["${data.aws_security_group.securitygroup.id}"]
  key_name                    = var.key_name
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 60
    delete_on_termination = false
  }
  tags = {
    Name = var.ec2_name
  }

  #excute docker-compose on remote ec2 instance
  provisioner "remote-exec" {
    inline = [
      "echo ''",
      "echo ${self.private_ip}",
      "sudo hostnamectl set-hostname snipeit",

      "echo ''",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("sshkey.pem")
      host        = self.private_ip
    }
  }
} //end of EC2 RTS
