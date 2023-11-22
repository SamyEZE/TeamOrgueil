#!/usr/bin/bash

if [ $# -ne 1 ]; then
    echo "Un argument attendu exactement"
    exit
else
    chemin=$1
    if [ ! -f "$chemin" ]; then
        echo "On attend un fichier qui existe"
        exit
    fi
fi

# Début du fichier HTML avec Bulma
echo "<html>"
echo "<head>"
echo "    <meta charset='UTF-8'>"
echo "    <title>Tableau des URL</title>"
echo "    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.3/css/bulma.min.css'>"
echo "</head>"
echo "<body>"

# Barre de navigation
echo "    <nav class='navbar is-primary' role='navigation' aria-label='main navigation'>"
echo "        <div class='navbar-menu'>"
echo "            <div class='navbar-start'>"
echo "                <a class='navbar-item' href='../../index.html'>Accueil</a>"
echo "                <a class='navbar-item' href='tableau.html'>Tableau</a>"
echo "            </div>"
echo "        </div>"
echo "    </nav>"

echo "    <section class='section'>"
echo "        <div class='container'>"
echo "            <table class='table is-bordered is-striped is-narrow is-hoverable is-fullwidth'>"
echo "                <thead>"
echo "                    <tr>"
echo "                        <th>Numéro</th>"
echo "                        <th>URL</th>"
echo "                        <th>Code</th>"
echo "                        <th>Encodage</th>"
echo "                    </tr>"
echo "                </thead>"
echo "                <tbody>"

lineN=1

# Lecture du fichier ligne par ligne et traitement
while read -r line; do
    code=$(curl -s -I -L -w "%{http_code}" -o /dev/null "$line")
    encodage=$(curl -s -I -L -w "%{content_type}" -o /dev/null "$line" | grep -P -o "charset=\S+" | cut -d"=" -f2 | tail -n 1)
    
    # Écriture de la ligne du tableau
    echo "                    <tr>"
    echo "                        <td>${lineN}</td>"
    echo "                        <td><a href='${line}' target='_blank'>${line}</a></td>"
    echo "                        <td>${code}</td>"
    echo "                        <td>${encodage}</td>"
    echo "                    </tr>"
    lineN=$((lineN + 1))
done < "$chemin"

# Fin du fichier HTML
echo "                </tbody>"
echo "            </table>"
echo "        </div>"
echo "    </section>"
echo "</body>"
echo "</html>"
