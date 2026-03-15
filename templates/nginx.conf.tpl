server {
    listen 80;
    listen [::]:80;
    server_name __DOMAIN__;
    location /vmess { proxy_pass http://127.0.0.1:10000; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
    location /vless { proxy_pass http://127.0.0.1:10001; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
    location /trojan-ws { proxy_pass http://127.0.0.1:10002; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
    location / { return 200 'Katsu Panel'; add_header Content-Type text/plain; }
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;
    server_name __DOMAIN__;
    ssl_certificate __XRAY_DIR__/xray.crt;
    ssl_certificate_key __XRAY_DIR__/xray.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    location /vmess { proxy_pass http://127.0.0.1:10000; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
    location /vless { proxy_pass http://127.0.0.1:10001; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
    location /trojan-ws { proxy_pass http://127.0.0.1:10002; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; }
    location /vmess-grpc { grpc_set_header X-Real-IP $remote_addr; grpc_set_header Host $host; grpc_pass grpc://127.0.0.1:10003; }
    location /vless-grpc { grpc_set_header X-Real-IP $remote_addr; grpc_set_header Host $host; grpc_pass grpc://127.0.0.1:10004; }
    location /trojan-grpc { grpc_set_header X-Real-IP $remote_addr; grpc_set_header Host $host; grpc_pass grpc://127.0.0.1:10005; }
}
