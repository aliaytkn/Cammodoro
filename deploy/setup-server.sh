#!/usr/bin/env bash
# One-time setup, run ON the Hostinger VPS from your Mac:
#   ssh root@179.198.213.113 'bash -s' < deploy/setup-server.sh
# Safe to re-run: it only installs what is missing and updates the checkout.
set -euo pipefail

DOMAIN="${DOMAIN:-cammodoro.camenos.com}"
APP_DIR="${APP_DIR:-/var/www/cammodoro}"
REPO="${REPO:-https://github.com/aliaytkn/cammodoro.git}"

echo "==> Checking what is listening on port 80"
if ss -ltnp 2>/dev/null | grep -E ':80\s' | grep -qv nginx; then
  echo "!! Something other than nginx owns port 80:"; ss -ltnp | grep -E ':80\s'
  echo "   Stop here — tell me what it is (Docker/Traefik/Caddy?) and I will adapt the config."; exit 1
fi

echo "==> Installing nginx, git, certbot if missing"
export DEBIAN_FRONTEND=noninteractive
need=""
command -v nginx   >/dev/null || need="$need nginx"
command -v git     >/dev/null || need="$need git"
command -v certbot >/dev/null || need="$need certbot python3-certbot-nginx"
if [ -n "$need" ]; then apt-get update -qq && apt-get install -y -qq $need; fi

echo "==> Fetching the app into $APP_DIR"
mkdir -p "$(dirname "$APP_DIR")"
if [ -d "$APP_DIR/.git" ]; then git -C "$APP_DIR" pull --ff-only; else git clone "$REPO" "$APP_DIR"; fi

echo "==> Configuring nginx for $DOMAIN"
cp "$APP_DIR/deploy/nginx-cammodoro.conf" /etc/nginx/sites-available/cammodoro
ln -sf /etc/nginx/sites-available/cammodoro /etc/nginx/sites-enabled/cammodoro
nginx -t
systemctl enable --now nginx >/dev/null 2>&1 || true
systemctl reload nginx

if command -v ufw >/dev/null && ufw status | grep -q "Status: active"; then
  echo "==> Opening firewall for web traffic"; ufw allow 'Nginx Full' >/dev/null || { ufw allow 80/tcp; ufw allow 443/tcp; }
fi

echo "==> HTTPS certificate"
if getent hosts "$DOMAIN" >/dev/null; then
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email --redirect
else
  echo "!! $DOMAIN does not resolve yet. Add the DNS A record -> this server's IP, wait a few minutes, then re-run this script."
  exit 1
fi

echo "==> Done. Check: https://$DOMAIN"
curl -sS -o /dev/null -w "HTTP %{http_code}\n" "https://$DOMAIN/" || true
