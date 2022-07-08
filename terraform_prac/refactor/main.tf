resource "null_resource" "foo" {}
resource "null_resource" "bar" {}

# null_resource.bar: Creation complete after 0s [id=6356411977043912714]
# null_resource.foo: Creation complete after 0s [id=4084023082036331241]

resource "aws_instance" "remove" {
  ami           = "ami-0c3fd0f5d33134a76"
  instance_type = "t3.micro"
}
# id=i-01dafbe5bd72da225
