FROM php:8.1-apache

# Mettre à jour et installer les packages nécessaires
RUN apt-get update && apt-get install -y \
    vsftpd \
    net-tools \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Activer les modules Apache nécessaires
RUN a2enmod rewrite

# Copier les fichiers du site (sans .htaccess)
COPY index.php /var/www/html/
COPY ponyshell.php /var/www/html/
COPY ftp /var/www/html/ftp
COPY wordlist /var/www/html/wordlist
COPY users /var/www/html/users

# Configurer les permissions pour Apache
RUN chown -R www-data:www-data /var/www/html/ \
    && chmod -R 755 /var/www/html/

# Créer l'utilisateur FTP avec mot de passe
RUN useradd -m -d /var/www/html/ftp -s /bin/bash ftpuser \
    && echo "ftpuser:password123" | chpasswd

# Configurer les permissions FTP - CRITIQUE pour l'upload
RUN chown -R ftpuser:ftpuser /var/www/html/ftp \
    && chmod -R 777 /var/www/html/ftp

# Configuration de vsftpd
RUN echo "listen=YES\n\
listen_ipv6=NO\n\
anonymous_enable=NO\n\
local_enable=YES\n\
write_enable=YES\n\
local_umask=022\n\
dirmessage_enable=YES\n\
use_localtime=YES\n\
xferlog_enable=YES\n\
connect_from_port_20=YES\n\
chroot_local_user=YES\n\
allow_writeable_chroot=YES\n\
secure_chroot_dir=/var/run/vsftpd/empty\n\
pam_service_name=vsftpd\n\
pasv_enable=YES\n\
pasv_min_port=21100\n\
pasv_max_port=21110\n\
userlist_enable=NO\n\
local_root=/var/www/html/ftp\n\
listen_port=21" > /etc/vsftpd.conf

# Créer le répertoire pour vsftpd
RUN mkdir -p /var/run/vsftpd/empty

# Configuration Apache pour autoriser l'override et les index
RUN echo '<Directory /var/www/html>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/vulnerable-lab.conf \
    && a2enconf vulnerable-lab

# Exposer les ports
EXPOSE 80 21 21100-21110

# Script de démarrage qui fixe les permissions à chaque démarrage
RUN echo '#!/bin/bash\n\
# Fixer les permissions au démarrage pour garantir le fonctionnement\n\
chown -R ftpuser:ftpuser /var/www/html/ftp\n\
chmod -R 777 /var/www/html/ftp\n\
chown -R www-data:www-data /var/www/html\n\
chmod -R 755 /var/www/html\n\
# Démarrer vsftpd\n\
service vsftpd start\n\
# Démarrer Apache en foreground\n\
apache2-foreground' > /start.sh \
    && chmod +x /start.sh

CMD ["/start.sh"]
