
#!/bin/bash
echo "Installing updates"
sudo yum update -y
echo "Installing Apache"
sudo yum install -y httpd.x86_64
echo "Starting Apache"
sudo systemctl start httpd.service
echo "Enabling Apache"
sudo systemctl enable httpd.service
echo "Installing Git"
sudo yum install git -y
cd / && cd /home
#Checking if directory ci/cd project directory exists
if [ -d "ci-cd-pipeline-project" ]; then
	sudo rm -rf ci-cd-pipeline-project/
fi
echo "Cloning Git"
git clone https://github.com/forte001/ci-cd-pipeline-project.git
echo "Changing to cloned git directory"
cd ci-cd-pipeline-project/
cd ..
echo "Copying content of cloned git directory to var/www/html"
cd /home/ci-cd-pipeline-project/
cp index.html styles.css README.md  /var/www/html/
echo "Deployment Successful!"