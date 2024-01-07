#!/bin/bash

 

# Avant d'exécuter le script principal (script.sh),on va attribuer les droits d'exécution aux scripts et Lors de l'exécution de script.sh, celui-ci appelle automatiquement ce script pour générer le concordancier.


# Vérifie si le nombre d'arguments est correct
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 [Language] [Word] [Context File Path]"
    exit 1
fi

# Attribution des arguments aux variables
LANGUAGE=$1
WORD=$2
CONTEXT_FILE_PATH=$3

# Définition des variables pour les chemins de sortie
OUTPUT_DIR="../concordances/$LANGUAGE"
FILE_NAME=$(basename -- "$CONTEXT_FILE_PATH")
OUTPUT_FILE="$OUTPUT_DIR/${FILE_NAME%.txt}.html"

# Crée le dossier de sortie s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

# Génère le début du fichier HTML
echo "<!DOCTYPE html>
<html lang=\"$LANGUAGE\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Concordance de $WORD</title>
    <link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.3/css/bulma.min.css\">
    <style>
        td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: center;
        }
        .word {
            font-weight: bold;
        }
    </style>
</head>
<body>
    <section class=\"section\">
        <div class=\"container\">
            <h1 class=\"title\">Concordance de '$WORD' dans $LANGUAGE</h1>
            <table class=\"table is-bordered is-striped is-narrow is-hoverable is-fullwidth\">
                <thead>
                    <tr><th>Mots précédents</th><th>Occurrence</th><th>Mots suivants</th></tr>
                </thead>
                <tbody>" > "$OUTPUT_FILE"

# Lit le fichier et construit le tableau
while IFS= read -r line; do
    # Extrait les mots précédents contenant le mot recherché
    before=($(grep -ioP "(?:\S+\s)*$WORD" <<< "$line" | tr -s ' ' | cut -d' ' -f1-5))
    # Extrait les mots suivants contenant le mot recherché
    after=($(grep -ioP "$WORD\s(?:\S+\s)*" <<< "$line" | tr -s ' ' | cut -d' ' -f2-6))

    # Vérifie si les deux tableaux sont vides
    if [ ${#before[@]} -eq 0 ] && [ ${#after[@]} -eq 0 ]; then
        continue
    fi

    # Ajoute une ligne au fichier HTML avec les mots précédents, le mot actuel et les mots suivants
    echo "<tr><td>${before[@]:0:5}</td><td class=\"word\">$WORD</td><td>${after[@]:1:5}</td></tr>" >> "$OUTPUT_FILE"
done < "$CONTEXT_FILE_PATH"

# Génère le pied de page HTML
echo "        </tbody>
            </table>
        </div>
    </section>
</body>
</html>" >> "$OUTPUT_FILE"

# Affiche un message indiquant que le fichier HTML a été généré
echo "Le fichier HTML pour la concordance de $WORD a été généré."

