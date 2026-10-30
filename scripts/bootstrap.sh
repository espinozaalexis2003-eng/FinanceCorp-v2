#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/financecorp-bootstrap.log) 2>&1

APP_BUCKET="${app_bucket}"
SERVER_NAME="${server_name}"

echo "Starting FinanceCorp v2 on $SERVER_NAME"

# Install system dependencies
# AWS CLI v2 is normally included with the Amazon Linux 2023 AMI.
# Install the packages required to run FinanceCorp.
dnf install -y nginx python3.11 python3.11-pip unzip

# Stop immediately if the AWS CLI is unavailable.
command -v aws >/dev/null 2>&1 || {
  echo "ERROR: AWS CLI is unavailable."
  exit 1
}

# Create application directories
mkdir -p /opt/financecorp/wheels

# Download application from private S3
aws s3 cp \
  "s3://$APP_BUCKET/application/app.py" \
  /opt/financecorp/app.py

aws s3 cp \
  "s3://$APP_BUCKET/application/requirements.txt" \
  /opt/financecorp/requirements.txt

aws s3 cp \
  "s3://$APP_BUCKET/application/financecorp-wheels.zip" \
  /opt/financecorp/wheels.zip

# Extract Python dependencies
unzip -q /opt/financecorp/wheels.zip \
  -d /opt/financecorp/wheels

# Create virtual environment
python3.11 -m venv /opt/financecorp/venv

# Install dependencies offline
/opt/financecorp/venv/bin/pip install \
  --no-index \
  --find-links=/opt/financecorp/wheels \
  -r /opt/financecorp/requirements.txt

# Configure Gunicorn
cat > /etc/systemd/system/financecorp.service <<EOF
[Unit]
Description=FinanceCorp Flask Application
After=network-online.target
Wants=network-online.target

[Service]
User=nginx
WorkingDirectory=/opt/financecorp
Environment=SERVER_NAME=$SERVER_NAME
ExecStart=/opt/financecorp/venv/bin/gunicorn \
  --workers 2 \
  --bind 127.0.0.1:5000 \
  app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Disable the default server block in nginx.conf.
# Our FinanceCorp server configuration will handle port 80.
sed -i '/^[[:space:]]*server[[:space:]]*{/,/^[[:space:]]*}/d' \
  /etc/nginx/nginx.conf

# Configure NGINX with one known server configuration
cat > /etc/nginx/nginx.conf <<'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    sendfile on;
    keepalive_timeout 65;

    server {
        listen 80 default_server;
        server_name _;

        location / {
            proxy_pass http://127.0.0.1:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# Remove previous FinanceCorp configuration to avoid duplicates
rm -f /etc/nginx/conf.d/financecorp.conf

# Ensure Gunicorn can read application files
chmod -R a+rX /opt/financecorp

# Verify NGINX configuration before starting
nginx -t

# Start services
systemctl daemon-reload
systemctl enable --now financecorp
systemctl enable --now nginx

echo "FinanceCorp v2 bootstrap completed."