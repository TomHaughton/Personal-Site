server {
        listen 80;

        server_name tomhaughton.com www.tomhaughton.com;

        return 307 https://www.$server_name$request_uri;
}

server {
        listen 443 ssl;

        ssl on;
        ssl_certificate_key /etc/letsencrypt/live/www.tomhaughton.com/privkey.pem;
        ssl_certificate /etc/letsencrypt/live/www.tomhaughton.com/fullchain.pem;

        root /home/tom/Personal-Site;
        index index.html;

        server_name www.tomhaughton.com;

        location / {
                try_files $uri $uri/ =404;
        }
}

server {
        listen 80;

        server_name jenkins.tomhaughton.com;

        location / {
                proxy_set_header   X-Real-IP $remote_addr;
                proxy_set_header   Host      $http_host;
                proxy_pass         http://localhost:8080;
                proxy_cache_use_stale  error timeout invalid_header updating
                http_500 http_502 http_503 http_504;
        }
}

server {
        listen 80;

        server_name blog.tomhaughton.com www.tomhaughton.com;

        return 307 http://www.$server_name$request_uri;
}

server {
        listen 80;

        server_name www.blog.tomhaughton.com;

        location / {
                proxy_set_header   X-Real-IP $remote_addr;
                proxy_set_header   Host      $http_host;
                proxy_pass         http://localhost:2368;
                proxy_cache_use_stale  error timeout invalid_header updating
                http_500 http_502 http_503 http_504;
        }
}
