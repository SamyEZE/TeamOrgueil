#!/usr/bin/bash

# Vérification du nombre d'arguments
if [ $# -ne 2 ]; then
    echo "On attend deux arguments"
    exit 1
fi

chemin=$1
mot_etude=$2

# Vérification de l'existence du fichier
if [ ! -f "$chemin" ]; then
    echo "On attend un fichier qui existe"
    exit 1
fi


# Début du fichier HTML avec style Bulma
echo "<html>" > tableaux/tableau_"$2".html
echo "<head><title>Tableau des URL du mot "$2"</title><link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.3/css/bulma.min.css\"></head>" >> tableaux/tableau_"$2".html
echo "<body>" >> tableaux/tableau_"$2".html
echo "<section class=\"section\">" >> tableaux/tableau_"$2".html
echo "<div class=\"container\">" >> tableaux/tableau_"$2".html
echo "<table class=\"table is-bordered is-striped is-fullwidth\">" >> tableaux/tableau_"$2".html
echo "<tr><th>Numéro</th><th>URLs</th><th>Code</th><th>Encodage</th><th>Aspiration</th><th>Dump</th><th>Compte</th><th>Contextes</th></tr>" >> tableaux/tableau_"$2".html

lineN=1

# Lecture du fichier ligne par ligne et traitement
while read -r line; do
    filename=$(basename "$line")

    code=$(curl -s -I -L -w "%{http_code}" -o /dev/null "$line")
    #if [[ $code -ne 200 ]]; then
        #continue
    #fi
    #--> cette condition est correcte mais pour l'instant, elle exclut plusieurs ligne d'urls, donc on la laisse en commentaire le temps de trouver d'autres URLs

    encodage=$(curl -s -I -L -w "%{content_type}" -o /dev/null "$line" | grep -P -o "charset=\S+" | cut -d"=" -f2 | tail -n 1)
    if [[ ! $encodage ]]; then
        encodage="UTF-8"
    fi

    # Aspiration de la page par cURL
    curl -s "$line" > "aspirations/aspiration_${filename}.html"

    # Récupération du dump textuel avec Lynx
    lynx -dump "$line" > "dumps-text/dump_${filename}.txt"

    # Comptage des occurrences du mot d'étude
    compte=$(grep -o -i "$mot_etude" "dumps-text/dump_${filename}.txt" | wc -l)
    #if [[ $compte -eq 0 ]]; then
        #continue
    #fi
    #--> cette condition est correcte mais pour l'instant, elle exclut plusieurs ligne d'urls, donc on la laisse en commentaire le temps de trouver d'autres URLs

    # Récupération des contextes d'apparition du mot
    contextes=$(grep -C 2 -i "$mot_etude" "dumps-text/dump_${filename}.txt")
    echo "$contextes" > "contextes/contexte_${filename}.txt"

    # Écriture de la ligne du tableau HTML
    echo "<tr><td>${lineN}</td><td><a href='${line}' >${line}</a></td><td>${code}</td><td>${encodage}</td><td><a href=\"aspirations/aspiration_${filename}.html\">aspiration</a></td><td><a href=\"dumps-text/dump_${filename}.txt\">dump</a></td><td>${compte}</td><td><a href=\"contextes/contexte_${filename}.txt\">contextes</a></td></tr>" >> tableaux/tableau_"$2".html



    lineN=$((lineN + 1))
done < "$chemin"

# Fin du fichier HTML
echo "</table>" >> tableaux/tableau_"$2".html
echo "</div>" >> tableaux/tableau_"$2".html
echo "</section>" >> tableaux/tableau_"$2".html
echo "</body>" >> tableaux/tableau_"$2".html
echo "</html>" >> tableaux/tableau_"$2".html

echo "Tableau HTML généré : tableau_"$2".html"

