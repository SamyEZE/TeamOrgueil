#!/bin/bash

file=$1

# Vérification qu'un seul argument a été fourni au script
if [ $# -ne 1 ]; then
    echo "Ce script demande en argument un fichier d'URLs."
    exit 1
fi

counter=1

# Début du document HTML avec Bulma CSS et barre de navigation
echo "<!DOCTYPE html>"
echo "<html>"
echo "<head>"
echo "    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.3/css/bulma.min.css'>"
echo "</head>"
echo "<body>"
echo "    <!-- Barre de navigation -->"
echo "    <nav class='navbar' role='navigation' aria-label='main navigation'>"
echo "        <div class='navbar-menu'>"
echo "            <div class='navbar-start'>"
echo "                <a class='navbar-item' href='index.html'>Accueil</a>"
echo "                <a class='navbar-item' href='tableau.html'>Tableau</a>"
echo "            </div>"
echo "        </div>"
echo "    </nav>"

# Début du tableau HTML avec classes Bulma
echo "    <!-- Tableau -->"
echo "    <table class='table is-bordered is-striped is-narrow is-hoverable is-fullwidth'>"
echo "        <tr><th>N°</th><th>URL</th><th>Code Réponse</th><th>Encodage</th></tr>"

# Lecture du fichier ligne par ligne et remplissage du tableau
while read -r line; do
    infos_page=$(curl -L -I -s -o /dev/null -w "%{http_code}\t%{content_type}" "$line")

    code_reponse=$(echo "$infos_page" | cut -f1)
    encodage=$(echo "$infos_page" | cut -f2 | sed -n 's/.*charset=\(.*\)/\1/p')

    # Ajout d'une ligne au tableau HTML pour chaque URL
    echo "        <tr><td>${counter}</td><td>${line}</td><td>${code_reponse}</td><td>${encodage}</td></tr>"

    ((counter++))
done < "$file"

# Fin du tableau et du document HTML
echo "    </table>"
echo "</body>"
echo "</html>"
