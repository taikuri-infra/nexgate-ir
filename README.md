# NexGate Landing Page

Landing page for [nexgate.ir](https://nexgate.ir) — Enterprise Remote Access Security Platform.

## Quick Install (Fresh Server)

One command on a fresh Ubuntu/Debian or CentOS server:

```bash
curl -fsSL https://raw.githubusercontent.com/taikuri-infra/nexgate-ir/main/install.sh | sudo bash
```

Custom domain:

```bash
curl -fsSL https://raw.githubusercontent.com/taikuri-infra/nexgate-ir/main/install.sh | sudo bash -s mydomain.com
```

## What it does

1. Installs **nginx**
2. Downloads `index.html` to `/var/www/nexgate/`
3. Configures nginx with security headers + gzip
4. Starts and enables nginx

## SSL (Let's Encrypt)

After install:

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d nexgate.ir -d www.nexgate.ir
```

## Manual Install

```bash
sudo apt install nginx -y
sudo mkdir -p /var/www/nexgate
sudo curl -fsSL https://raw.githubusercontent.com/taikuri-infra/nexgate-ir/main/index.html -o /var/www/nexgate/index.html
# Configure nginx to serve /var/www/nexgate
sudo systemctl restart nginx
```
