#!/usr/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 chemin/vers/urls.txt langue(francais, espagnol, arabe, turc)"
    exit 1
fi

URLS=$1
LANGUE=$2

if [ ! -f "$URLS" ]; then
    echo "Le fichier spécifié n'existe pas."
    exit 1
fi

LANGUE_ATTENDUE="francais|espagnol|arabe|turc"
if [[ ! $LANGUE =~ $LANGUE_ATTENDUE ]]; then
    echo "La langue doit être francais, espagnol, arabe ou turc."
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "curl n'est pas installé. Veuillez l'installer."
    exit 1
fi

OUTPUT_FILE="tableau_${LANGUE}.html"
{
echo "<html>"
echo "<head>"
echo "    <meta charset='UTF-8'>"
echo "    <title>Tableau des URL - ${LANGUE}</title>"
echo "    <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/bulma/0.9.3/css/bulma.min.css'>"
echo "</head>"
echo "<body>"

echo "    <nav class='navbar is-primary' role='navigation' aria-label='main navigation'>"
echo "        <div class='navbar-menu'>"
echo "            <div class='navbar-start'>"
echo "                <a class='navbar-item' href='../../index.html'>Accueil</a>"
echo "                <a class='navbar-item' href='tableau_${LANGUE}.html'>Tableau</a>"
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
echo "                        <th>Aspiration</th>"
echo "                        <th>Dump</th>"
echo "                        <th>Code HTTP</th>"
echo "                        <th>Encodage</th>"
echo "                    </tr>"
echo "                </thead>"
echo "                <tbody>"

lineN=1

while read -r line; do
    if [[ ! $line =~ ^https?:// ]]; then
        echo "URL non valide: $line"
        continue
    fi

    response=$(curl -s -I -L -w "%{http_code}" -o /dev/null "$line")
    encodage=$(curl -s -I -L -w "%{content_type}" -o /dev/null "$line" | grep -P -o "charset=\S+" | cut -d"=" -f2 | tail -n 1)

    FICHIER_ASPIRATION="../aspirations/${LANGUE}/aspiration${lineN}.html"
    curl -s -L "$line" > "$FICHIER_ASPIRATION"

    FICHIER_DUMP="../dump-texts/${LANGUE}/dump${lineN}.txt"
    lynx -dump "$line" > "$FICHIER_DUMP"

    echo "                    <tr>"
    echo "                        <td>${lineN}</td>"
    echo "                        <td><a href='${line}' target='_blank'>${line}</a></td>"
    echo "                        <td><a href='$FICHIER_ASPIRATION'>Aspiration</a></td>"
    echo "                        <td><a href='$FICHIER_DUMP'>Dump</a></td>"
    echo "                        <td>${response}</td>"
    echo "                        <td>${encodage}</td>"
    echo "                    </tr>"
    lineN=$((lineN + 1))
done < "$URLS"

echo "                </tbody>"
echo "            </table>"
echo "        </div>"
echo "    </section>"
echo "</body>"
echo "</html>"
} > $OUTPUT_FILE
