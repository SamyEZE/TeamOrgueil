#!/usr/bin/env bash

# Vérification des arguments
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <chemin_dossier> <langue>"
    exit 1
fi

chemin_dossier=$1
langue=$2
output_dir="./itrameur"
output_file="${output_dir}/$(basename $chemin_dossier)-${langue}.txt"

# Création du répertoire de sortie si nécessaire
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir" || { echo "Erreur lors de la création du répertoire ${output_dir}"; exit 1; }
fi

# Initialisation du fichier de sortie
echo "<lang=\"$langue\">" > "$output_file"

# Traitement des fichiers
shopt -s nullglob
for fichier in "${chemin_dossier}/${langue}"*.txt; do
    if [ -f "$fichier" ]; then
        page=$(basename "$fichier" .txt)
        contenu=$(cat "$fichier" | sed 's/&/&amp;/g' | sed 's/</&lt;/g' | sed 's/>/&gt;/g')
        echo "<page=\"${page}\">" >> "$output_file"
        echo "<text>${contenu}</text>" >> "$output_file"
        echo "</page> §" >> "$output_file"
    fi
done

# Ajout de la balise de fermeture
echo "</lang>" >> "$output_file"

echo "Le fichier de sortie a été créé : ${output_file}"
