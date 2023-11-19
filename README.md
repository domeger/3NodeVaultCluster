
# 3 Node Vault Cluster for Anjuna Runtime

## Introduction
This project deploys a high-availability three-node cluster using Consul and HashiCorp Vault. It's designed to provide a robust and secure environment for managing secrets and configurations in distributed systems by protecting it in an Anjuna Runtime for in-use isolation.

## Project Description
The 3 Node Vault Cluster leverages Consul for high availability and HashiCorp Vault for secure secrets management. This setup ensures reliable, scalable, and secure storage and management of sensitive data.

## Installation and Setup
To deploy the cluster:
1. Ensure prerequisites like Docker are installed.
2. Make sure to register on downloads.anjuna.io for your API Key.
3. Clone this repository.
4. Run the setup script provided to initialize the cluster.

## High Availability Configuration
The cluster is configured with Consul to ensure high availability. Follow the steps in `ha_config.md` to set up and verify the HA configuration.

## HashiCorp Vault Integration
HashiCorp Vault is integrated into the cluster for secure secrets management. For setup details, refer to `vault_integration.md`.

## Usage and Management
Once deployed, the cluster can be managed through standard Docker and Consul commands. For detailed usage instructions, see `usage.md`.

## Troubleshooting and Support
For common issues and troubleshooting tips, refer to `troubleshooting.md`. For additional support, join our community forum or contact us at dom.eger@anjuna.io

## Contributing
Contributions are welcome! Please refer to `CONTRIBUTING.md` for guidelines on submitting pull requests and participating in the project's development.

## License
This project is licensed under the GPL-3.0 license. For more details, see the `LICENSE` file.

## Acknowledgements
Thanks to all contributors and supporters who have made this project possible.
