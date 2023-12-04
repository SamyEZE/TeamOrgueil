#!/bin/bash

# Usage: ./make_itrameur_corpus.sh <dossier_dumps> <dossier_contextes> <lang_code>
# Example: ./make_itrameur_corpus.sh dumps-text contextes es

dossier_dumps=$1
dossier_contextes=$2
lang_code=$3
output_dir="itrameur"

# Créer le dossier de sortie s'il n'existe pas
mkdir -p "$output_dir"

# Fonction pour transformer les fichiers (dumps ou contextes)
process_files() {
    local input_dir=$1
    local output_prefix=$2
    local tag_name=$3

    for file in "$input_dir"/*; do
        local file_number=$(basename "$file")
        file_number="${file_number#*_}"

        # Préparation du fichier de sortie
        local output_file="$output_dir/$output_prefix-$lang_code.txt"

        # Ajout du début du pseudo-XML
        if [ ! -f "$output_file" ]; then
            echo "<lang=\"$lang_code\">" > "$output_file"
        fi

        # Transformation du fichier et ajout au fichier de sortie
        echo "<$tag_name=\"$lang_code-$file_number\">" >> "$output_file"
        sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$file" | while IFS= read -r line || [[ -n "$line" ]]; do
            echo "<text>$line</text>" >> "$output_file"
        done
        echo "</$tag_name> §" >> "$output_file"
    done

    # Ajout de la fin du pseudo-XML
    echo "</lang>" >> "$output_file"
}

# Processus les dumps textuels
process_files "$dossier_dumps" "dump" "page"

# Processus les contextes
process_files "$dossier_contextes" "contexte" "contexte"

# Combiner tous les fichiers de contexte individuels en un seul fichier
# Utiliser '>>' pour ajouter à la fin du fichier existant au lieu de le remplacer
if [ ! -f "$output_dir/contexte.txt" ]; then
    echo "<lang=\"$lang_code\">" > "$output_dir/contexte.txt"
fi

for context_file in "$output_dir"/contexte-$lang_code.txt; do
    sed '1d;$d' "$context_file" >> "$output_dir/contexte.txt"
done

echo "</lang>" >> "$output_dir/contexte.txt"
