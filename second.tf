resource "aws_ebs_volume" "myvol" {
  availability_zone = "us-east-1a"
  size = 13

tags = {
   Name = "HelloWorld"
}
}
