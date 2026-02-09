<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechShop - Boutique en ligne</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
        }
        header {
            background-color: #333;
            color: white;
            padding: 20px;
            text-align: center;
        }
        nav {
            background-color: #444;
            padding: 10px;
            text-align: center;
        }
        nav a {
            color: white;
            text-decoration: none;
            margin: 0 15px;
        }
        .container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
        }
        .products {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }
        .product {
            background: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .product h3 {
            margin-bottom: 10px;
            color: #333;
        }
        .product p {
            color: #666;
            margin-bottom: 10px;
        }
        .price {
            font-size: 24px;
            color: #e74c3c;
            font-weight: bold;
        }
        button {
            background-color: #3498db;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 10px;
        }
        button:hover {
            background-color: #2980b9;
        }
        footer {
            background-color: #333;
            color: white;
            text-align: center;
            padding: 20px;
            margin-top: 40px;
        }
    </style>
</head>
<body>
    <header>
        <h1>🛒 TechShop</h1>
        <p>Votre boutique de technologie en ligne</p>
    </header>
    
    <nav>
        <a href="index.php">Accueil</a>
        <a href="index.php?page=products">Produits</a>
        <a href="index.php?page=contact">Contact</a>
        <a href="index.php?page=about">À propos</a>
    </nav>
    
    <div class="container">
        <?php
        // Vulnérabilité LFI (Local File Inclusion)
        if(isset($_GET['page'])) {
            $page = $_GET['page'];
            include($page . '.php');
        } else {
        ?>
        
        <h2>Produits populaires</h2>
        <div class="products">
            <div class="product">
                <h3>Laptop Pro X</h3>
                <p>Ordinateur portable haute performance</p>
                <p class="price">1299€</p>
                <button>Ajouter au panier</button>
            </div>
            
            <div class="product">
                <h3>Smartphone Ultra</h3>
                <p>Le dernier smartphone à la pointe de la technologie</p>
                <p class="price">899€</p>
                <button>Ajouter au panier</button>
            </div>
            
            <div class="product">
                <h3>Tablette Pro</h3>
                <p>Tablette professionnelle avec stylet</p>
                <p class="price">599€</p>
                <button>Ajouter au panier</button>
            </div>
            
            <div class="product">
                <h3>Écouteurs Premium</h3>
                <p>Qualité sonore exceptionnelle</p>
                <p class="price">249€</p>
                <button>Ajouter au panier</button>
            </div>
            
            <div class="product">
                <h3>Montre Connectée</h3>
                <p>Suivez votre santé et vos activités</p>
                <p class="price">349€</p>
                <button>Ajouter au panier</button>
            </div>
            
            <div class="product">
                <h3>Caméra 4K</h3>
                <p>Capturez vos moments en ultra HD</p>
                <p class="price">799€</p>
                <button>Ajouter au panier</button>
            </div>
        </div>
        
        <?php } ?>
    </div>
    
    <footer>
        <p>&copy; 2026 TechShop - Tous droits réservés</p>
        <p>Version 1.0.5</p>
    </footer>
</body>
</html>
