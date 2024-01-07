##JOURNAL DE BORD

#1ère semaine du travail en groupe
On a commencé par reconstruire le script étape par étape suivant ce qu'on avait fait au mini-projet. Cependant, on a eu plusieurs problèmes, notamment la commande curl qui ne récupérait pas les pages web correctement ou la commande lynx qui n'arrivait pas à accéder aux pages web. On a donc dû faire plusieurs modifications jusqu'à la dernière minute mais on avait toujours un problème avec les fichiers URLs qui ne voulaient pas être traités correctement. On a pû aspirer les pages web dans le dossier aspirations, créer l'index, lancer la page web et il ne nous reste qu'à perfectionner le tableau produit par le script (l'enrichir avec Bulma).


#2ème semaine du travail en groupe
Script iTrameur

Nous avons travaillé sur la création d'un script Bash pour préparer des fichiers pour iTrameur, un outil d'analyse textuelle. Notre objectif était de développer make_itrameur_corpus.sh, un script qui transforme des fichiers textuels en un format pseudo-XML pour iTrameur, traitant à la fois des fichiers de dumps textuels et de contextes.
Nous avons rencontré des difficultés avec les chemins de fichiers incorrects, menant à des erreurs de "fichier non trouvé". Cela a nécessité une révision pour nous assurer de la précision des chemins.
Ensuite, nous avons adapté le script pour traiter divers fichiers en plusieurs langues ce qui a ajouté de la complexité.
Un défi majeur était d'ajouter du contenu aux fichiers existants sans les écraser. Nous avons résolu cela en utilisant la redirection >>.

Conclusion :
Malgré les défis, nous sommes satisfaits des résultats. Ce projet a amélioré notre compréhension des scripts Bash et du traitement de données textuelles, renforçant nos compétences en programmation et en résolution de problèmes.

Début du travail :

Après avoir fait une courte pause pour se consacrer aux examens d'autres matières, nous avons repris notre travail. Nous avons effectué un récapitulatif de notre projet :

    Mot d'étude : "Orgueil". Nous nous sommes également intéressés au mot "fierté" en raison de l'ambiguïté entre orgueil et fierté.
    Langues choisies : français, anglais, espagnol et turc.
    Initialement, nous avions choisi l'arabe, mais en raison du manque de corpus, nous avons décidé de le remplacer par l'anglais.

Le but de cette étude de corpus en anglais (réalisée par Lydia), en français (par Alexandra), en espagnol (par Samy) et en turc (par Melissa) est de traiter et de comparer les mots "pride," "orgullo," et "gurur," qui signifient à la fois orgueil et fierté selon le contexte. Nous visons un minimum de 50 URL pour chaque mot.
Reprise du script de base :
Pendant les semaines de cours, nous avions déjà élaboré un script pour le traitement des URLs et un autre pour iTrameur. Nous étions conscients que cela ne correspondait pas aux corrections des professeurs, car nous n'avions pas utilisé les chemins relatifs et n'avions pas respecté l'arborescence indiquée. Cependant, tant que cela générait correctement les fichiers d'aspiration, de dump et de contextes, ainsi que les codes HTTP, les nombres d'occurrences et l'encodage, nous n'avions pas identifié de problème. Ce n'est que lorsque nous avons tenté de créer le site web que nous avons rencontré des difficultés, notamment avec les liens vers les pages aspirées qui ne fonctionnaient pas.
Nous avons alors travaillé sur l'ajustement du script de base. En parallèle, nous travaillions sur le script du concordancier, où nous avons décidé de créer deux scripts distincts. Lors de l'exécution du premier script, nous faisons appel au script "concordancier.sh" pour générer les tableaux corrects avec toutes les colonnes requises. Pour le script "concordancier", nous avons opté pour la même expression permettant de créer les contextes (5 mots avant, mot cible, 5 mots après).

Une précision sur une ligne de notre script de base : while IFS= read -r URL; do. Cette ligne diffère de ce qui a été vu en classe. Nous l'avons ajoutée car deux membres de notre groupe, Melissa et Sami, ont rencontré des problèmes avec Linux (ils l'ont perdu) et ont donc continué le travail avec WSL de Windows, ce qui n'était pas évident pour eux. L'utilisation de IFS nous a permis de ne pas faire de différence entre les espaces et les tabulations dans Linux et Windows.
Nous avons également modifié le script d'iTrameur qui ne correspondait pas exactement à ce qui était demandé, notamment en termes du nombre d'arguments requis, mais aussi en ce qui concerne l'appellation des noms de fichiers générés. Le problème principal était que les fichiers générés ne respectaient pas le format demandé par iTrameur. Finalement, nous avons pu générer les fichiers requis, et pour le fichier de contextes global, nous l'avons créé manuellement.
