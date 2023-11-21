 #!/bin/bash
set -eo pipefail

MY_API_KEY=$(cat /home/ec2-user/api_key_file)

# Install AWS Nitro Enclaves CLI and required packages
sudo amazon-linux-extras install -y aws-nitro-enclaves-cli
echo "Installing AWS Nitro Dev and OpenSSL Env"
sudo yum install -y aws-nitro-enclaves-cli-devel jq openssl11-libs

# Modify EC2 User
echo "Modifying EC2 User"
sudo usermod -aG ne ec2-user

# Add EC2-USER to Docker Group
echo "Adding EC2-USER to Docker Group"
sudo usermod -aG docker ec2-user

# Install AWS Nitro Runtime
echo "Installing AWS Nitro Runtime"
sudo wget https://api.downloads.anjuna.io/v1/releases/anjuna-nitro-runtime.1.36.0003.tar.gz --header="X-Anjuna-Auth-Token:$MY_API_KEY" -O "/home/ec2-user/anjuna-nitro-runtime.1.36.0003.tar.gz"
sudo mkdir -p /opt/anjuna/nitro
sudo tar -xzvo -C /opt/anjuna/nitro -f /home/ec2-user/anjuna-nitro-runtime.1.36.0003.tar.gz

# Install AWS Nitro Runtime License
echo "Installing AWS Nitro Runtime License"
sudo wget "https://api.downloads.anjuna.io/v1/releases/license/nitro/license.yaml" --header="X-Anjuna-Auth-Token:$MY_API_KEY" -O "/opt/anjuna/license.yaml"

# Install Docker
echo "Installing Docker"
sudo yum install -y docker

# Enable Docker
echo "Enable Docker"
sudo systemctl enable docker

# Enable Kernel Module
echo "Enable Kernel Module"
echo 'KERNEL=="vsock", MODE="660", GROUP="ne"' | sudo tee /etc/udev/rules.d/51-vsock.rules

# Reload UDEVADM
echo "Reloading UDEVADM"
sudo udevadm control --reload

# Trigger UDEVADM
echo "Trigger UDEVADM"
sudo udevadm trigger

# Change Allocator Memory
echo "Change Allocator Memory"
sudo sed -i 's/^memory_mib:.*/memory_mib: 8192/' /etc/nitro_enclaves/allocator.yaml

# Change Allocator CPU
echo "Change Allocator CPU"
sudo sed -i 's/^cpu_count:.*/cpu_count: 2/' /etc/nitro_enclaves/allocator.yaml

# Start Allocator
echo "Starting Allocator"
sudo systemctl restart nitro-enclaves-allocator.service
sudo systemctl enable nitro-enclaves-allocator.service

# Start and Enable Docker
echo "Start and Enable Docker"
sudo systemctl restart docker && sudo systemctl enable docker

# Enable Net Cap
echo "Net Cap Enabled"
sudo setcap cap_net_bind_service=+ep /opt/anjuna/nitro/bin/anjuna-nitro-netd-parent

# Create Log Directory
echo "Create Log Directory"
sudo mkdir -p /var/log/nitro_enclaves
sudo chown ec2-user:ec2-user /var/log/nitro_enclaves/

# Add the export statement to the ~/.bash_profile for root and ec2-user
echo 'export PATH=$PATH:/opt/anjuna/nitro/bin' | sudo tee -a /root/.bash_profile >> ~/.bash_profile

# Source the ~/.bash_profile for the current user
source ~/.bash_profile

# Define the IP addresses for the Consul nodes
IP_ADDRESS_1="10.0.0.10"
IP_ADDRESS_2="10.0.0.11"
IP_ADDRESS_3="10.0.0.12"

# Get the private IP address of the instance
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Install Consul
yum install -y jq

# Create the Consul configuration file
cat <<EOF > /etc/consul.hcl
datacenter = "dc1"
server = true
bootstrap_expect = 3
data_dir = "/opt/consul"
retry_join = ["$IP_ADDRESS_1", "$IP_ADDRESS_2", "$IP_ADDRESS_3"]
bind_addr = "$PRIVATE_IP"
EOF

echo "Consul configuration file (consul.hcl) created with predefined IP addresses:"
cat /etc/consul.hcl

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Install Consul (you may need to adjust this depending on your OS and installation method)
# Example for installing Consul via YUM
sudo yum install -y consul

# Create a systemd service unit file for Consul
sudo cat <<DELIMITER > /etc/systemd/system/consul.service
[Unit]
Description=HashiCorp Consul
Documentation=https://www.consul.io/

[Service]
ExecStart=/usr/bin/consul agent -config-file=/etc/consul.d/consul.hcl
Restart=always
User=consul
Group=consul
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
DELIMITER

# Create the Consul configuration directory
sudo mkdir -p /etc/consul.d
sudo mv /etc/consul.hcl /etc/consul.d/

# Start and enable the Consul service
sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul

# Check the status of the Consul service
sudo systemctl status consul
