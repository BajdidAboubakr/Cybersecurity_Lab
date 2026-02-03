<?php
// Protection basique - mais le fichier peut être téléchargé directement
header('HTTP/1.0 403 Forbidden');
echo '<h1>403 Forbidden</h1>';
echo '<p>Accès refusé à ce répertoire.</p>';
?>
