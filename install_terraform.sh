
#!/bin/bash


  sudo curl -o terraform_0.15.1_linux_amd64.zip https://releases.hashicorp.com/terraform/0.15.1/terraform_0.15.1_linux_amd64.zip
  sudo unzip -o terraform_0.15.1_linux_amd64.zip -d /bin
  sudo apt update
  sudo apt install software-properties-common
  sudo add-apt-repository ppa:deadsnakes/ppa -y
  sudo apt install python3.7 python3-pip
  pip3 install --upgrade pip
  pip3 install --upgrade --user awscli
  export PATH=$PATH:./bin/