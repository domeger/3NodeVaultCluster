
# High Availability Configuration with Consul

This document outlines the steps to set up high availability for a cluster using Consul.

## Steps for Setup

1. **Define the IP Addresses for the Consul Nodes**:
   ```bash
   IP_ADDRESS_1="10.0.0.10"
   IP_ADDRESS_2="10.0.0.11"
   IP_ADDRESS_3="10.0.0.12"
   ```

2. **Get the Private IP Address of the Instance**:
   ```bash
   PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
   ```

3. **Install Consul**:
   ```bash
   yum install -y jq
   ```

4. **Create the Consul Configuration File**:
   ```bash
   cat <<EOF > /etc/consul.hcl
   datacenter = "dc1"
   server = true
   bootstrap_expect = 3
   data_dir = "/opt/consul"
   retry_join = ["$IP_ADDRESS_1", "$IP_ADDRESS_2", "$IP_ADDRESS_3"]
   bind_addr = "$PRIVATE_IP"
   EOF
   ```

5. **Install Consul Repository**:
   ```bash
   sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
   ```

6. **Install Consul via YUM**:
   ```bash
   sudo yum install -y consul
   ```

7. **Create a Systemd Service Unit File for Consul**:
   ```bash
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
   ```

8. **Create the Consul Configuration Directory and Move Configuration File**:
   ```bash
   sudo mkdir -p /etc/consul.d
   sudo mv /etc/consul.hcl /etc/consul.d/
   ```

9. **Start and Enable the Consul Service**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable consul
   sudo systemctl start consul
   ```

10. **Check the Status of the Consul Service**:
    ```bash
    sudo systemctl status consul
    ```

Following these steps will set up a high-availability cluster using Consul.
