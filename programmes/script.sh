#!/usr/bin/env bash

# Vérifie si l'argument du chemin du fichier est fourni
if [[ $# -ne 1 ]]; then
    echo "Usage : $0 chemin_du_fichier"
    exit
fi

URLS=$1
MOT=$FICHIER

# Obtient le nom de base du fichier sans l'extension .txt et convertit en minuscules
FICHIER=$(basename "$1" .txt | tr '[:upper:]' '[:lower:]')

# Associe le nom du fichier à une langue
case $FICHIER in
    "orgueil")
        LANGUE="fr"
        ;;
    "pride")
        LANGUE="en"
        ;;
    "orgullo")
        LANGUE="es"
        ;;
    "gurur")
        LANGUE="tr"
        ;;
    *)
        echo "Langue non supportée"
        exit 1
        ;;
esac

# Définition du fichier de sortie
OUTPUT_FILE="../tableaux/tableau_${LANGUE}.html"

# Création de l'en-tête du fichier HTML
cat <<EOF > $OUTPUT_FILE
<!DOCTYPE html>
<html lang="$LANGUE">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableaux - Projet de Groupe</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.3/css/bulma.min.css">
    <style>
        .hero-background {
            background: url('Org.png') center center;
            background-size: cover;
        }
        .hero-title {
            font-size: 4rem;
            color: white;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
            font-family: 'Arial', sans-serif;
        }
    </style>
</head>
<body>
    <section class="hero is-fullheight hero-background">
        <div class="hero-body">
            <div class="container has-text-centered">
                <h1 class="title hero-title">
                    Tableau de $MOT
                </h1>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <table class="table is-striped is-narrow is-hoverable is-fullwidth">
                <thead>
                    <tr>
                        <th>Nº ligne</th>
                        <th>URL</th>
                        <th>Aspiration</th>
                        <th>Dump</th>
                        <th>Contexte</th>
                        <th>Concordancier</th>
                        <th>Code HTTP</th>
                        <th>Encodage</th>
                        <th>Compte</th>
                    </tr>
                </thead>
EOF

lineno=1

# Boucle de lecture de chaque ligne du fichier d'URLs
while read -r URL; do
    FICHIER_ASPIRATION="../aspirations/${LANGUE}-${lineno}.html"

    response=$(curl -s -L -w "%{http_code}" -o "$FICHIER_ASPIRATION" "$URL")
    encoding=$(curl -s -I -L -w "%{content_type}" -o /dev/null "$URL" | grep -o "charset=\S+" | cut -d"=" -f2 | tail -n 1 | tr '[:lower:]' '[:upper:]')
    COMPTE=0
    FICHIER_DUMP="NA"
    FICHIER_CONTEXTE="NA"
    CONCORDANCIER="NA"

    if [ $response -eq 200 ]; then
        # Création du dump texte
        if [[ ! $encoding == "UTF-8" ]]; then
            iconv -f "$encoding" -t "UTF-8" "$FICHIER_ASPIRATION" > "temp.html"
            mv "temp.html" "$FICHIER_ASPIRATION"
            encoding="UTF-8"
        fi
        FICHIER_DUMP="../dump-texts/${LANGUE}-${lineno}.txt"
        lynx -assume_charset="UTF-8" -dump -nolist "$FICHIER_ASPIRATION" > "$FICHIER_DUMP"

        COMPTE=$(grep -i -o "$MOT" $FICHIER_DUMP | wc -l)

        FICHIER_CONTEXTE="../contextes/${LANGUE}-${lineno}.txt"
        grep -i -C 3 "$MOT" $FICHIER_DUMP > $FICHIER_CONTEXTE

        programmes/concordancier.sh $MOT $lineno $FICHIER_CONTEXTE $LANGUE
        CONCORDANCIER="../concordances/${LANGUE}-${lineno}.html"
        echo "<tbody>
            <tr>
                <th>$lineno</th><td>$URL</td><td><a href='$FICHIER_ASPIRATION'>Aspiration</a></td><td><a href='$FICHIER_DUMP'>Dump</a></td><td><a href='$FICHIER_CONTEXTE'>Contexte</a></td><td><a href='$CONCORDANCIER'>Concordancier</a></td><td>$response</td><td>$encoding</td><td>$COMPTE</td>
            </tr>
            </tbody>" >> $OUTPUT_FILE
    else
        FICHIER_ASPIRATION="NA"
        echo "<tbody>
            <tr>
                <th>$lineno</th><td>$URL</td><td>$FICHIER_ASPIRATION</td><td>$FICHIER_DUMP</td><td>$FICHIER_CONTEXTE</td><td>$CONCORDANCIER</td><td>$response</td><td>$encoding</td><td>$COMPTE</td>
            </tr>
            </tbody>" >> $OUTPUT_FILE
    fi
    lineno=$(expr $lineno + 1)
    echo "Traitement de l'URL $lineno terminé"
done < "$URLS"

echo "         </table>
        </div>
</body>
</html>" >> $OUTPUT_FILE

echo "gg wp"

