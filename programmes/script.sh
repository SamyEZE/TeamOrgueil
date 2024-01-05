#!/usr/bin/env bash

# Vérifie si l'argument du chemin du fichier est fourni
if [[ $# -ne 1 ]]; then
    echo "Usage : $0 fichier_des_urls"
    exit 1
fi

# Préparation des chemins relatifs
URLS_FILE="../URLs/$1"
FICHIER=$(basename "$URLS_FILE" .txt)
OUTPUT_DIR="../tableaux"
ASPIRATION_DIR="../aspirations"
DUMP_TEXTS_DIR="../dump-texts"
CONTEXTE_DIR="../contextes"
CONCORDANCES_DIR="../concordances"

# Création des répertoires nécessaires s'ils n'existent pas
mkdir -p "$OUTPUT_DIR" "$ASPIRATION_DIR" "$DUMP_TEXTS_DIR" "$CONTEXTE_DIR" "$CONCORDANCES_DIR"

# Association du nom du fichier à une langue
case $FICHIER in
    "fierté")
        LANGUE="fr1"  # Modifier ici pour "fr1"
        ;;
    "pride")
        LANGUE="en"
        ;;
    "orgueil")
        LANGUE="fr2"  # Modifier ici pour "fr2"
        ;;
    "orgullo")
        LANGUE="es"
        ;;
    "gurur")
        LANGUE="tr"
        ;;
    *)
        echo "Langue non reconnue à partir du nom du fichier."
        exit 1
        ;;
esac

# Nom du fichier de sortie
OUTPUT_FILE="$OUTPUT_DIR/tableau_$LANGUE.html"


# Création de l'en-tête du fichier HTML
cat <<EOF > "$OUTPUT_FILE"
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
                    Tableau de $FICHIER
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
                <tbody>
EOF

lineno=1

# Boucle de lecture de chaque ligne du fichier d'URLs
while IFS= read -r URL; do
    if [ -z "$URL" ]; then
        # Si la ligne est vide, on passe à la suivante
        continue
    fi

    FICHIER_ASPIRATION="$ASPIRATION_DIR/${LANGUE}-${lineno}.html"
    FICHIER_DUMP="$DUMP_TEXTS_DIR/${LANGUE}-${lineno}.txt"
    FICHIER_CONTEXTE="$CONTEXTE_DIR/${LANGUE}-${lineno}.txt"
    CONCORDANCIER="$CONCORDANCES_DIR/${LANGUE}/${LANGUE}-${lineno}.html"

    response=$(curl -s -L -w "%{http_code}" -o "$FICHIER_ASPIRATION" "$URL")

    if [ "$response" -ne 200 ]; then
        echo "URL $lineno : Réponse HTTP non 200, URL ignorée."
        lineno=$((lineno + 1))
        continue
    fi

    # Analyse du fichier aspiration pour créer un dump
    lynx -assume_charset="UTF-8" -dump -nolist "$FICHIER_ASPIRATION" > "$FICHIER_DUMP"

    # Compte les occurrences du mot
    COMPTE=$(grep -i -o "$FICHIER" "$FICHIER_DUMP" | wc -l)
    if [ "$COMPTE" -eq 0 ]; then
        echo "URL $lineno : Aucune occurrence de '$FICHIER', URL ignorée."
        lineno=$((lineno + 1))
        continue
    fi

    # Extraction du contexte autour des occurrences du mot
    grep -i -C 3 "$FICHIER" "$FICHIER_DUMP" > "$FICHIER_CONTEXTE"

    # Appel au script concordancier
    ./concordancier.sh "$LANGUE" "$FICHIER" "$FICHIER_CONTEXTE"

    # Ajout des informations dans le fichier HTML
    echo "<tr>" >> "$OUTPUT_FILE"
    echo "<th>$lineno</th>" >> "$OUTPUT_FILE"
    echo "<td><a href='$URL'>$URL</a></td>" >> "$OUTPUT_FILE"
    echo "<td><a href='$FICHIER_ASPIRATION'>Aspiration</a></td>" >> "$OUTPUT_FILE"
    echo "<td><a href='$FICHIER_DUMP'>Dump</a></td>" >> "$OUTPUT_FILE"
    echo "<td><a href='$FICHIER_CONTEXTE'>Contexte</a></td>" >> "$OUTPUT_FILE"
    echo "<td><a href='$CONCORDANCIER' target='_blank'>Concordancier</a></td>" >> "$OUTPUT_FILE"
    echo "<td>$response</td>" >> "$OUTPUT_FILE"
    echo "<td>UTF-8</td>" >> "$OUTPUT_FILE"
    echo "<td>$COMPTE</td>" >> "$OUTPUT_FILE"
    echo "</tr>" >> "$OUTPUT_FILE"

    lineno=$((lineno + 1))
done < "$URLS_FILE"

# Fermeture des balises HTML
echo "                </tbody>
            </table>
        </div>
    </section>
</body>
</html>" >> "$OUTPUT_FILE"

echo "Traitement terminé"
