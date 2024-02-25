#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 -d <domain> [-w <webroot_dir>] [-n <nginx_config_file>] [-h]"
    echo "Options:"
    echo "  -d, --domain            Domain name for the SSL certificate (required)"
    echo "  -w, --webroot-dir       Webroot directory for the webroot plugin (optional)"
    echo "  -n, --nginx-config      Nginx configuration file for the standalone plugin (optional)"
    echo "  -h, --help              Display this help message"
    exit 1
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--domain)
            DOMAIN="$2"
            shift
            shift
            ;;
        -w|--webroot-dir)
            WEBROOT_DIR="$2"
            shift
            shift
            ;;
        -n|--nginx-config)
            NGINX_CONFIG="$2"
            shift
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option: $key"
            usage
            ;;
    esac
done

# Check if domain is provided
if [ -z "$DOMAIN" ]; then
    echo "Error: Domain name is required."
    usage
fi

# Check if either webroot directory or nginx configuration file is provided
if [ -z "$WEBROOT_DIR" ] && [ -z "$NGINX_CONFIG" ]; then
    echo "Error: Either webroot directory or nginx configuration file must be provided."
    usage
fi

# Determine plugin based on provided options
if [ -n "$WEBROOT_DIR" ]; then
    PLUGIN="--webroot -w $WEBROOT_DIR"
elif [ -n "$NGINX_CONFIG" ]; then
    PLUGIN="--nginx --nginx-ctl /usr/sbin/nginx --nginx-server-root /etc/nginx --nginx-config $NGINX_CONFIG"
fi

# Obtain SSL certificate using Certbot
certbot certonly --non-interactive --agree-tos --email admin@$DOMAIN -d $DOMAIN $PLUGIN

# Check if certificate issuance was successful
if [ $? -eq 0 ]; then
    echo "SSL certificate for domain $DOMAIN has been successfully obtained."
else
    echo "Error: Failed to obtain SSL certificate for domain $DOMAIN."
fi
