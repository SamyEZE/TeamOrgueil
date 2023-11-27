#!/bin/bash

# Vérifiez que l'utilisateur entre le fichier d'URLs et la langue
if [ $# -ne 2 ]; then
    echo "Ce script nécessite deux arguments : fichier d'URLs et langue."
    exit 1
fi

# Vérifie la validité de la langue
langue=$2
case $langue in
    "français"|"espagnol"|"turc"|"arabe")
        ;;
    *)
        echo "La langue doit être 'français', 'espagnol', 'turc' ou 'arabe'."
        exit 1
        ;;
esac

# Chemins de stockage
ASPIRATION_DIR="./aspirations/${langue}"
EXTRACTION_DIR="./extractions/${langue}"
CONTEXT_DIR="./contextes/${langue}"
TABLEAU_HTML="./tableaux/tableau_${langue}.html"

mkdir -p $ASPIRATION_DIR $EXTRACTION_DIR $CONTEXT_DIR "$(dirname "$TABLEAU_HTML")"
compte=$(grep -o -i "orgueil" "${EXTRACTION_DIR}/extraction${compteur}.txt" | wc -l)
# Initialisation du tableau HTML
cat <<EOF > $TABLEAU_HTML
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tableau - $langue</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.3/css/bulma.min.css">
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
            <a class="navbar-item" href="tableauar.html">Arabe</a>
        </div>
    </div>
</nav>
</head>
<body>
    <section class="section">
        <div class="container">
            <h1 class="title">Données sur le Mot "Orgueil" en $langue</h1>
            <table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
                <thead>
                    <tr>
                        <th>URL</th>
                        <th>Nombre d'occurrences</th>
                        <th>Encodage</th>
                        <th>Code</th>
                        <th>Lien Aspiration</th>
                        <th>Lien Extraction</th>
                        <th>Lien Contexte</th>
                    </tr>
                </thead>
                <tbody>
EOF

# Lire les URLs depuis le fichier
compteur=1
while read -r URL; do
    if [ -n "$URL" ]; then
            # Logique de traitement pour chaque URL
            curl -o "${ASPIRATION_DIR}/aspiration${compteur}.html" -w "%{http_code}" -L "$URL" > temp.txt
if [ ! -f "${ASPIRATION_DIR}/aspiration${compteur}.html" ]; then
    echo "Erreur : échec du téléchargement de $URL"
    continue
fi

            code=$(<temp.txt)
            lynx -dump -nolist "${ASPIRATION_DIR}/aspiration${compteur}.html" > "${EXTRACTION_DIR}/extraction${compteur}.txt"
            encodage=$(file -bi "${ASPIRATION_DIR}/aspiration${compteur}.html" | sed -e 's/.*charset=//')
            if [ -f "${EXTRACTION_DIR}/extraction${compteur}.txt" ]; then
    grep -C 2 -i "orgueil" "${EXTRACTION_DIR}/extraction${compteur}.txt" > "${CONTEXT_DIR}/contexte${compteur}.txt"
else
    echo "Fichier d'extraction non trouvé : ${EXTRACTION_DIR}/extraction${compteur}.txt"
fi

            # Ajouter les informations au tableau HTML
            echo "                    <tr>
                        <td><a href='$URL'>$URL</a></td>
                        <td>$compte</td>
                        <td>$encodage</td>
                        <td>$code</td>
                        <td><a href='${ASPIRATION_DIR}/aspiration${compteur}.html'>Voir Aspiration</a></td>
                        <td><a href='${EXTRACTION_DIR}/extraction${compteur}.txt'>Voir Extraction</a></td>
                        <td><a href='${CONTEXT_DIR}/contexte${compteur}.txt'>Voir Contexte</a></td>
                    </tr>" >> $TABLEAU_HTML
            fi
    ((compteur++))
done < "$1"

# Fermeture du tableau et du fichier HTML
cat <<EOF >> $TABLEAU_HTML
                </tbody>
            </table>
        </div>
    </section>
</body>
</html>
EOF

echo "Tableau HTML généré : $TABLEAU_HTML"
rm temp.txt