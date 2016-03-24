# disk optimisations here
echo "*/5 * * * * root /sbin/swapoff -a" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root /bin/mount -o remount,noatime,nodiratime,nobh,nouser_xattr,barrier=0,commit=600 /" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo noop > /sys/block/vda/queue/scheduler" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 50 > /proc/sys/vm/dirty_ratio" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 50 > /proc/sys/vm/dirty_background_ratio" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 60000 > /proc/sys/vm/dirty_expire_centisecs" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 60000 > /proc/sys/vm/dirty_writeback_centisecs" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations
echo "*/5 * * * * root echo 99 > /proc/sys/vm/swappiness" | sudo tee -a /etc/cron.d/unsafe_disk_optimisations

# DNS setup here
sudo hostnamectl set-hostname websocketer
echo "websocketer" | sudo tee /etc/hostname
echo "127.0.1.1 websocketer" | sudo tee -a /etc/hosts

# Timezone setup here
echo "UTC" | sudo tee /etc/timezone
sudo dpkg-reconfigure tzdata

# ntp setup here
sudo ntpdate pool.ntp.org
sudo apt-get install -y ntp
sudo service ntp start

# general vm setup here
sudo apt-get update
sudo apt-get upgrade -y # this can take a while

# nginx setup here
sudo apt-get build-dep -y nginx
sudo mkdir /tmp/build_nginx_delete_me
cd /tmp/build_nginx_delete_me/
sudo apt-get source nginx
cd nginx-1.6.2/debian/modules
sudo curl -sL https://github.com/wandenberg/nginx-push-stream-module/tarball/master | sudo tar zx
sudo mv wandenberg-nginx-push-stream-module-b2056f6/ nginx-push-stream-module
cd ../..
sudo sed -i 's/--without-http_uwsgi_module \\/--without-http_uwsgi_module \\\n--add-module=$(MODULESDIR)\/nginx-push-stream-module \\/' debian/rules
sudo dpkg-buildpackage -b
cd ..
sudo dpkg -i nginx-common_1.6.2-5ubuntu3.1_all.deb nginx-light_1.6.2-5ubuntu3.1_amd64.deb
cd ~
sudo rm -Rf /tmp/build_nginx_delete_me
sudo cp /vagrant/files/config/nginx.conf /etc/nginx/nginx.conf
sudo service nginx restart

## apache setup here
#sudo apt-get install -y apache2
#sudo a2enmod {rewrite,proxy,proxy_wstunnel}
#sudo rm /etc/apache2/sites-enabled/000-default.conf
#sudo cp /vagrant/files/config/apache.conf /etc/apache2/sites-enabled/default.conf
#sudo service apache2 restart

# autossh setup here
sudo apt-get install -y autossh
sudo autossh -f -N -R 127.0.0.1:34521:127.0.0.1:80 -i /vagrant/files/keys/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no user@127.0.0.1

# cleanup here
sudo apt-get autoremove -y
sudo apt-get clean
sudo find /var/lib/apt/lists -type f -exec rm -v {} \;

# FIXES: "The SSH command responded with a non-zero exit status"
true
