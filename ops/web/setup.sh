# Ubuntu 12.04 from http://alestic.com/
# Ports:
#   8001 (HTTP)
#   8002 HTTP (redirect http to https)

export api=10.0.0.184:8010
export admin=10.0.0.184:9001
export domain=justcoin.com

sudo apt-get update
sudo apt-get upgrade -y

# nginx
sudo apt-get install -y nginx

cd ~
mkdir snow-web
cd snow-web
mkdir log
mkdir log public

# --- /home/ubuntu/snow-web/nginx.conf
tee /home/ubuntu/snow-web/nginx.conf << EOL
server {
    listen 8001;
    server_name ${domain};
    root /home/ubuntu/snow-web/public/;
    access_log /home/ubuntu/snow-web/log/access.log;
    error_log /home/ubuntu/snow-web/log/error.log;

    gzip on;
    gzip_http_version 1.1;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_proxied any;
    gzip_types text/plain text/html text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript text/x-js;
    gzip_buffers 16 8k;
    gzip_disable "MSIE [1-6]\.(?!.*SV1)";

    location ^/client$ {
        rewrite ^ https://${domain}/client/ permanent;
    }

    location /api {
        proxy_pass http://${api};
        rewrite ^/api(/.+)\$ \$1 break;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /admin {
        proxy_pass http://${admin};
        rewrite ^/admin(/?.*)\$ \$1 break;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}

server {
    listen 8002;
    server_name ${domain};
    rewrite ^ https://${domain}\$request_uri? permanent;
}
EOL

vim /home/ubuntu/snow-web/nginx.conf

# --- make site available and enabled
sudo ln nginx.conf /etc/nginx/sites-available/snow-web
sudo ln /etc/nginx/sites-available/snow-web /etc/nginx/sites-enabled/snow-web

sudo nginx -s reload

sudo reboot
