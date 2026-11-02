# Cammodoro

Pixel-matrix pomodoro timer for a second phone/tablet screen. Static PWA — no build step, no backend.
Open `index.html` through any HTTPS static host, then "Add to Home Screen".

Files: `index.html` (app), `sw.js` (offline), `manifest.webmanifest`, icons.
All timers and history live in the device's local storage.

Views (one button cycles them, or press `V`): **Timer** (BUSY / REST / FREE badge + countdown), **Clock** (HH:MM:SS with weekday bar, or classic HH:MM with sun/moon and a date ticker), **Weather** (animated icon + temperature via Open-Meteo, set a city or use location in Settings). The clock appears by itself after the timer has been idle for a minute. Finishing a pomodoro or break plays a chime/arcade/bowl sound and a ripple + confetti animation.

## Deploy (Hostinger VPS, nginx)
One-time server setup — see `deploy/nginx-cammodoro.conf`:

```bash
# DNS: A record  cammodoro.camenos.com -> VPS IP
sudo mkdir -p /var/www && cd /var/www
sudo git clone https://github.com/aliaytkn/cammodoro.git cammodoro   # use a deploy key if the repo is private
sudo cp cammodoro/deploy/nginx-cammodoro.conf /etc/nginx/sites-available/cammodoro
sudo ln -s /etc/nginx/sites-available/cammodoro /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d cammodoro.camenos.com
```

Update after changes: `git push`, then `./deploy/deploy.sh` (or `git pull` on the server).
When you change app files, bump `CACHE` in `sw.js` so installed devices refresh.
