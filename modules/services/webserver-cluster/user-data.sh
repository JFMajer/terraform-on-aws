#!/bin/bash

echo 'INSTANCE_ID="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
PRIVATE_IP="$(hostname -I)"
PUBLIC_IP="$(curl http://169.254.169.254/latest/meta-data/public-ipv4)"
PUBLIC_HOSTNAME="$(curl http://169.254.169.254/latest/meta-data/public-hostname)"

cat > index.html <<EOF
<h1>Hello, World</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
<hr>
<p>Loadbalances to EC2 instance of:
<ul>
		<li><strong>Instance ID</strong>: $INSTANCE_ID</li>
        <li><strong>Private IP</strong>: $PRIVATE_IP</li>
        <li><strong>Public IP</strong>: $PUBLIC_IP</li>
        <li><strong>Public DNS</strong>: $PUBLIC_HOSTNAME</li>
EOF

nohup busybox httpd -f -p "${server_port}" &