<?php
// Page affichant les fichiers FTP uploadés
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FTP Storage</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 5px;
        }
        h1 {
            color: #333;
        }
        .file-list {
            list-style: none;
            padding: 0;
        }
        .file-list li {
            padding: 10px;
            border-bottom: 1px solid #ddd;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .file-list li:hover {
            background-color: #f9f9f9;
        }
        a {
            color: #3498db;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .warning {
            background-color: #fff3cd;
            border: 1px solid #ffc107;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📁 FTP Storage Directory</h1>
        <div class="warning">
            ⚠️ Accès restreint - Fichiers FTP
        </div>
        
        <h2>Fichiers disponibles:</h2>
        <ul class="file-list">
            <?php
            $dir = __DIR__;
            $files = scandir($dir);
            
            foreach($files as $file) {
                if($file != '.' && $file != '..' && $file != 'index.php') {
                    $filepath = $dir . '/' . $file;
                    $filesize = filesize($filepath);
                    $filedate = date("Y-m-d H:i:s", filemtime($filepath));
                    
                    echo "<li>";
                    echo "<div>";
                    echo "<a href='$file'>$file</a><br>";
                    echo "<small>Taille: " . number_format($filesize) . " bytes | Date: $filedate</small>";
                    echo "</div>";
                    
                    // Permet l'exécution des fichiers PHP uploadés (vulnérabilité)
                    if(pathinfo($file, PATHINFO_EXTENSION) == 'php') {
                        echo "<span style='color: red;'>⚡ Exécutable</span>";
                    }
                    echo "</li>";
                }
            }
            ?>
        </ul>
        
        <p style="margin-top: 20px; color: #666;">
            <small>Total: <?php echo count($files) - 3; ?> fichier(s)</small>
        </p>
    </div>
</body>
</html>
