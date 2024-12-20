#!/bin/bash
yum -y update
yum -y install httpd


myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="silver">
<h2><font color="gold">My simple Html Webpage
<font color="green">Server PrivateIP: <font color="aqua">$myip<br><br>

<font color="magenta">
<b>Version 1.0</b>
</body>
</html>
EOF

sudo service httpd start
chkconfig httpd on