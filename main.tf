# Recuperar segredo usando um comando direto
data "external" "secret" {
  program = ["bash", "-c", "aws secretsmanager get-secret-value --secret-id facebook-senha --query SecretString --output text"]
}

resource "aws_instance" "amazon_linux" {
	ami		= "ami-04a81a99f5ec58529"
	instance_type	= "t2.micro"
	user_data = <<-EOF
              #!/bin/bash
              SECRET_JSON=$(echo '${data.external.secret.result}' | jq -r '.')
              USERNAME=$(echo $SECRET_JSON | jq -r '.username')
              PASSWORD=$(echo $SECRET_JSON | jq -r '.password')
              echo "export USERNAME=$USERNAME" >> /etc/profile.d/secrets.sh
              echo "export PASSWORD=$PASSWORD" >> /etc/profile.d/secrets.sh
              source /etc/profile.d/secrets.sh
              EOF
	key_name	= "terraform_key"
	vpc_security_group_ids	= ["sg-0df1360b26b4dd7a7"]
	subnet_id 		= "subnet-06e01937aac68ff59"
	tags = {
		Name = "teste-secretmanager"
	}
}

resource "aws_secretsmanager_secret" "minhas_senhas" {
  name        = "facebook-senha"
  description = "Este é um exemplo de segredo criado pelo Terraform"
}

resource "aws_secretsmanager_secret_version" "senha" {
  secret_id = aws_secretsmanager_secret.minhas_senhas.id
  secret_string = jsonencode({
    username = "guigo@gmail.com"
    password = "senhadomeufacebook.tenhoqueestudarmais"
  })
}

