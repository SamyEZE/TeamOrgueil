#!/bin/bash

# Vérifiez si le nombre d'arguments est correct
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 [Language] [Word] [Context Directory]"
    exit 1
fi

LANGUAGE=$1
WORD=$2
CONTEXT_DIR=$3
OUTPUT_DIR="./concordances/$LANGUAGE"

# Créez le dossier de sortie s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

# Fonction pour générer HTML
generate_html() {
    local file_path=$1
    local word=$2
    local language=$3
    local file_name=$(basename -- "$file_path")
    local html_file="${file_name%.txt}.html"
    local output_file="$OUTPUT_DIR/$html_file"

    # Entête HTML
    echo "<!DOCTYPE html>
<html lang=\"$language\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Contexte de $word</title>
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
            <h1 class=\"title\">Contexte de '$word' dans $language</h1>
            <table class=\"table is-bordered is-striped is-narrow is-hoverable is-fullwidth\">
                <thead>
                    <tr><th>Mots précédents</th><th>Occurrence</th><th>Mots suivants</th></tr>
                </thead>
                <tbody>" > "$output_file"

    # Lire le fichier et construire le tableau
    while IFS= read -r line; do
    before=($(grep -ioP "(?:\S+\s){0,5}$word" <<< "$line" | tr -s ' ' | cut -d' ' -f1-5))
    after=($(grep -ioP "$word\s(?:\S+\s){0,5}" <<< "$line" | tr -s ' ' | cut -d' ' -f2-6))


    if [ ${#before[@]} -ge 5 ] && [ ${#after[@]} -ge 5 ]; then
        if [ "${before[-1]}" != "$word" ]; then
            echo "<tr><td>${before[@]:0:5}</td><td class=\"word\">$WORD</td><td>${after[@]:1:5}</td></tr>" >> "$output_file"
        fi
    fi
done < "$file_path"



    # Pied de page HTML
    echo "        </tbody>
            </table>
        </div>
    </section>
</body>
</html>" >> "$output_file"
}

# Traitement de chaque fichier de contexte
for file in "$CONTEXT_DIR"/*; do
    if [[ -f $file ]]; then
        generate_html "$file" "$WORD" "$LANGUAGE"
    fi
done

echo "Les fichiers HTML ont été générés dans le dossier $OUTPUT_DIR."
