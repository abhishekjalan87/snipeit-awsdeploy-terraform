
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
      "sudo mkdir /root/docker-data/",
      "sudo systemctl stop firewalld",
      "sudo systemctl disable firewalld",
      "sudo docker run --name snipe-mysql --restart=always -d -e MYSQL_ROOT_PASSWORD=test@123 -e MYSQL_DATABASE=snipe -e MYSQL_USER=snipe -e MYSQL_PASSWORD=test@123 -e TZ=Europe/Berlin -p 127.0.0.1:3306:3306 -v /root/docker-data/snipe-mysql:/var/lib/mysql mysql:5.7.30 --sql-mode="" ",
      "sudo docker run -d --name=snipe-it --restart=always --link snipe-mysql:db -e MAIL_PORT_587_TCP_ADDR=smtp.gmail.com -e MAIL_PORT_587_TCP_PORT=465 -e MAIL_ENV_FROM_ADDR=test@test.de -e MAIL_ENV_FROM_NAME=IT-Admin -e MAIL_ENV_ENCRYPTION=ssl -e MAIL_ENV_USERNAME=test@test.de -e MAIL_ENV_PASSWORD=kuieddfggvjbm -e DB_CONNECTION=mysql -e DB_HOST=snipe-mysql -e DB_DATABASE=snipe -e DB_USERNAME=snipe -e DB_PASSWORD=test@123 -e APP_TIMEZONE=Europe/Berlin -e APP_KEY=base64:5U/KPKw1GN/Rz0fWYO/4FsSOqjmjvDAQzMCqwcAqstc= -v /root/docker-data/snipe-conf:/var/lib/snipeit -p 80:80 snipe/snipe-it:v4.9.2",
      "sudo docker ps -a",
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