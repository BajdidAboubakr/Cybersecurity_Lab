#!/bin/bash

# Script d'installation du lab vulnérable
# Usage: sudo ./setup.sh

echo "================================"
echo "  Installation du Lab Vulnérable"
echo "================================"
echo ""

# Vérifier si exécuté en tant que root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Ce script doit être exécuté en tant que root (utilisez sudo)" 
   exit 1
fi

# Variables
WEB_DIR="/var/www/html/vulnerable-lab"
FTP_USER="ftpuser"
FTP_PASS="password123"

echo "📦 Installation des dépendances..."
apt-get update
apt-get install -y apache2 php vsftpd

echo ""
echo "📁 Copie des fichiers dans $WEB_DIR..."
mkdir -p $WEB_DIR
cp -r ./* $WEB_DIR/
chown -R www-data:www-data $WEB_DIR
chmod -R 755 $WEB_DIR

echo ""
echo "👤 Création de l'utilisateur FTP: $FTP_USER..."
# Supprimer l'utilisateur s'il existe déjà
if id "$FTP_USER" &>/dev/null; then
    echo "   L'utilisateur existe déjà, suppression..."
    userdel -r $FTP_USER 2>/dev/null
fi

# Créer le nouvel utilisateur
useradd -m -d $WEB_DIR/ftp -s /bin/bash $FTP_USER
echo "$FTP_USER:$FTP_PASS" | chpasswd
chown -R $FTP_USER:$FTP_USER $WEB_DIR/ftp

echo ""
echo "⚙️  Configuration de vsftpd..."
cat > /etc/vsftpd.conf << EOF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
userlist_enable=NO
local_root=$WEB_DIR/ftp
listen_port=21
EOF

echo ""
echo "🔧 Configuration d'Apache..."
a2enmod rewrite
a2enmod headers

# Créer un virtual host
cat > /etc/apache2/sites-available/vulnerable-lab.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@vulnerable-lab.local
    DocumentRoot $WEB_DIR
    
    <Directory $WEB_DIR>
        Options +Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/vulnerable-lab-error.log
    CustomLog \${APACHE_LOG_DIR}/vulnerable-lab-access.log combined
</VirtualHost>
EOF

# Activer le site
a2ensite vulnerable-lab.conf

echo ""
echo "🔄 Redémarrage des services..."
systemctl restart vsftpd
systemctl restart apache2

# Vérifier le statut
echo ""
echo "📊 Statut des services:"
systemctl is-active --quiet apache2 && echo "   ✅ Apache: Actif" || echo "   ❌ Apache: Erreur"
systemctl is-active --quiet vsftpd && echo "   ✅ vsftpd: Actif" || echo "   ❌ vsftpd: Erreur"

echo ""
echo "================================"
echo "  ✅ Installation terminée!"
echo "================================"
echo ""
echo "📝 Informations importantes:"
echo "   - URL du site: http://localhost/vulnerable-lab/"
echo "   - IP du serveur: $(hostname -I | awk '{print $1}')"
echo "   - Utilisateur FTP: $FTP_USER"
echo "   - Mot de passe FTP: $FTP_PASS"
echo "   - Port FTP: 21"
echo "   - Port Web: 80"
echo ""
echo "🎯 Pour commencer le pentest:"
echo "   1. nmap -sV -sC <IP_DU_SERVEUR>"
echo "   2. gobuster dir -u http://<IP_DU_SERVEUR>/vulnerable-lab/ -w /usr/share/wordlists/dirb/common.txt"
echo "   3. wget http://<IP_DU_SERVEUR>/vulnerable-lab/wordlist/passwords.txt"
echo "   4. wget http://<IP_DU_SERVEUR>/vulnerable-lab/users/usernames.txt"
echo "   5. hydra -L usernames.txt -P passwords.txt ftp://<IP_DU_SERVEUR>"
echo ""
echo "⚠️  ATTENTION: Ce lab est INTENTIONNELLEMENT vulnérable!"
echo "   Ne l'exposez JAMAIS sur Internet!"
echo "   Utilisez-le uniquement dans un environnement isolé."
echo ""
