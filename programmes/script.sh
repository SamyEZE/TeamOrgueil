#!/usr/bin/env bash

# Vérification du nombre d'arguments
if [ $# -ne 2 ]; then
    echo "On attend deux arguments: chemin vers le fichier et mot d'étude"
    exit 1
fi

chemin=$1
mot_etude=$2

# Vérification de l'existence du fichier
if [ ! -f "$chemin" ]; then
    echo "Le fichier spécifié n'existe pas: $chemin"
    exit 1
fi

# Extraction du nom du fichier sans extension pour créer les sous-dossiers
base_filename=$(basename -- "$chemin")
filename_no_ext="${base_filename%.*}"

# Vérification et création des répertoires nécessaires
mkdir -p "aspirations/$filename_no_ext" "dumps-text/$filename_no_ext" "contextes/$filename_no_ext"

# Début du fichier HTML avec style Bulma
cat <<EOF > "tableaux/tableau_$filename_no_ext.html"
<html>
<head>
    <title>Tableau des URL du mot $mot_etude</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.3/css/bulma.min.css">
</head>
<body>
    <!-- Barre de navigation -->
    <nav class="navbar is-primary" role="navigation" aria-label="main navigation">
        <div class="navbar-brand">
            <a class="navbar-item" href="../index.html">
                Accueil
            </a>
        </div>
        <div class="navbar-menu">
            <div class="navbar-start">
                <a class="navbar-item" href="tableaufr.html">Français</a>
                <a class="navbar-item" href="tableaues.html">Espagnol</a>
                <a class="navbar-item" href="tableautr.html">Turc</a>
                <a class="navbar-item" href="tableauar.html">Anglais</a>
            </div>
        </div>
    </nav>

    <section class="section">
        <div class="container">
            <table class="table is-bordered is-striped is-fullwidth">
                <tr>
                    <th>Numéro</th>
                    <th>URLs</th>
                    <th>Code</th>
                    <th>Encodage</th>
                    <th>Aspiration</th>
                    <th>Dump</th>
                    <th>Compte</th>
                    <th>Contextes</th>
                </tr>
EOF

lineN=1

# Lecture du fichier ligne par ligne et traitement
while IFS= read -r line; do
    sanitized_filename=$(echo "$line" | md5sum | cut -d' ' -f1)  # Create a sanitized filename based on URL hash

    code=$(curl -s -I -L -w "%{http_code}" -o /dev/null "$line")
    if [[ $code -ne 200 ]]; then
        echo "URL did not return a successful status: $line (HTTP $code)"
        continue
    fi
    encodage=$(curl -s -I -L -w "%{content_type}" -o /dev/null "$line" | grep -o "charset=\S*" | cut -d"=" -f2 | tail -n 1)
    encodage=${encodage:-UTF-8}  # Default to UTF-8 if not found

    # Aspiration de la page par cURL
    curl -s "$line" > "aspirations/$filename_no_ext/aspiration_${sanitized_filename}.html"

    # Récupération du dump textuel avec Lynx
    lynx -dump "$line" > "dumps-text/$filename_no_ext/dump_${sanitized_filename}.txt"

    # Comptage des occurrences du mot d'étude
    compte=$(grep -c -i "$mot_etude" "dumps-text/$filename_no_ext/dump_${sanitized_filename}.txt")

    # Si le compte est zéro, afficher un message et passer à l'URL suivante
    if [[ $compte -eq 0 ]]; then
        echo "This URL : $line has 0 occurrence"
        continue
    fi

    # Récupération des contextes d'apparition du mot
    contextes=$(grep -C 2 -i "$mot_etude" "dumps-text/$filename_no_ext/dump_${sanitized_filename}.txt")
    echo "$contextes" > "contextes/$filename_no_ext/contexte_${sanitized_filename}.txt"

    # Écriture de la ligne du tableau HTML
    cat <<EOF >> "tableaux/tableau_$filename_no_ext.html"
                <tr>
                    <td>${lineN}</td>
                    <td><a href='${line}'>${line}</a></td>
                    <td>${code}</td>
                    <td>${encodage}</td>
                    <td><a href="aspirations/$filename_no_ext/aspiration_${sanitized_filename}.html">aspiration</a></td>
                    <td><a href="dumps-text/$filename_no_ext/dump_${sanitized_filename}.txt">dump</a></td>
                    <td>${compte}</td>
                    <td><a href="contextes/$filename_no_ext/contexte_${sanitized_filename}.txt">contextes</a></td>
                </tr>
EOF

    lineN=$((lineN + 1))
done < "$chemin"

# Fin du fichier HTML
cat <<EOF >> "tableaux/tableau_$filename_no_ext.html"
            </table>
        </div>
    </section>
</body>
</html>
EOF

echo "Tableau HTML généré : tableaux/tableau_$filename_no_ext.html"
