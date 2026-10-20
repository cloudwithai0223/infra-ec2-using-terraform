#!/bin/bash
set -euxo pipefail

# Update packages and install Nginx
apt-get update -y
apt-get install -y nginx

# Start Nginx and enable it at boot
systemctl enable nginx
systemctl start nginx

# Replace the default Nginx welcome page
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>My Terraform Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #eef2f7;
            text-align: center;
            padding-top: 100px;
        }
        .container {
            background: white;
            padding: 40px;
            margin: auto;
            max-width: 650px;
            border-radius: 12px;
        }
        h1 { color: #1769aa; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to My Website!</h1>
        <h2>Thanks to Inayat & Hari BABA!</h2>
        <p>Nginx is running successfully on AWS EC2.</p>
        <p>Provisioned using Terraform and automated with Shell Script.</p>
    </div>
</body>
</html>
HTML
