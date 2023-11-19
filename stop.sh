anjuna-nitro-cli terminate-enclave --all

# Also terminate the network bridge between enclave and parent
# in case there are changes to the exposed ports.
pkill -f "anjuna-nitro-netd-parent"

# Same for the filesystem proxy
pkill -f "anjuna-fs-proxy"
