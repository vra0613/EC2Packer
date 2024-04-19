packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "jenkins-master" {
  ami_description = "Redhat Linux Image with Jenkins server"
  ami_name        = "Jenkins-master-{{timestamp}}"
  instance_type   = "${var.instance_type}"
  region          = "${var.region}"
  source_ami      = "${var.source_ami}"
  ssh_username    = "ec2-user"
  vpc_id          = "vpc-1492097e"
  subnet_id       = "subnet-5c11af20"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 30 # Adjust size as needed
    volume_type           = "gp2"
    encrypted             = true # Enable encryption
    delete_on_termination = true # Delete volume on instance termination
  }

  tags = {
    "Name"        = "Jenkins Master"
    "Environment" = "Sandbox"
    "OS_vserion"  = "Redhat Enterprise Linux 9"
    "Created-by"  = "Packer"
  }

}

build {
  name    = "jenkins-master"
  sources = ["source.amazon-ebs.jenkins-master"]

  provisioner "file" {
    source      = "./scripts"
    destination = "/tmp/"
  }

  provisioner "shell" {
    execute_command = "sudo -E -S sh '{{.Path}}'"
    script          = "./setup-jenkins-master.sh"
  }

}