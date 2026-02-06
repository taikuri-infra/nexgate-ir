#!/bin/bash
set -e

# NexGate Landing Page Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/taikuri-infra/nexgate-ir/main/install.sh | bash

DOMAIN="${1:-nexgate.ir}"
REPO="https://raw.githubusercontent.com/taikuri-infra/nexgate-ir/main"
WEB_ROOT="/var/www/nexgate"

echo "========================================"
echo "  NexGate Landing Page Installer"
echo "  Domain: $DOMAIN"
echo "========================================"
echo ""

# Check root
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Run as root: sudo bash install.sh"
    exit 1
fi

# Detect OS
if [ -f /etc/debian_version ]; then
    PKG="apt"
elif [ -f /etc/redhat-release ]; then
    PKG="yum"
else
    echo "[ERROR] Unsupported OS. Use Ubuntu/Debian or CentOS/RHEL."
    exit 1
fi

# Install nginx
echo "[1/4] Installing nginx..."
if ! command -v nginx &>/dev/null; then
    if [ "$PKG" = "apt" ]; then
        apt update -qq && apt install -y -qq nginx
    else
        yum install -y -q nginx
    fi
    echo "  -> nginx installed"
else
    echo "  -> nginx already installed"
fi

# Download landing page
echo "[2/4] Downloading landing page..."
mkdir -p "$WEB_ROOT"
curl -fsSL "$REPO/index.html" -o "$WEB_ROOT/index.html"
echo "  -> index.html downloaded to $WEB_ROOT"

# Configure nginx
echo "[3/4] Configuring nginx..."
cat > /etc/nginx/sites-available/nexgate <<NGINX
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN www.$DOMAIN;

    root $WEB_ROOT;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Cache static assets
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Gzip
    gzip on;
    gzip_types text/html text/css application/javascript;
    gzip_min_length 256;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINX

# Enable site
if [ -d /etc/nginx/sites-enabled ]; then
    ln -sf /etc/nginx/sites-available/nexgate /etc/nginx/sites-enabled/nexgate
    rm -f /etc/nginx/sites-enabled/default
else
    # CentOS/RHEL — put config in conf.d
    cp /etc/nginx/sites-available/nexgate /etc/nginx/conf.d/nexgate.conf
fi

nginx -t
echo "  -> nginx configured for $DOMAIN"

# Start nginx
echo "[4/4] Starting nginx..."
systemctl enable nginx
systemctl restart nginx
echo "  -> nginx running"

echo ""
echo "========================================"
echo "  DONE!"
echo "  http://$DOMAIN"
echo "========================================"
echo ""
echo "Optional: Install SSL with Let's Encrypt:"
echo "  apt install certbot python3-certbot-nginx -y"
echo "  certbot --nginx -d $DOMAIN -d www.$DOMAIN"
echo ""
