# Analyse exploratoire des réservations hôtelières

Projet sommatif UA2 – Analyse exploratoire des données (AED) réalisée en R.

## Objectif

Explorer un jeu de données de réservations de deux hôtels (City Hotel et Resort Hotel) afin de repérer ce qui mérite d'être approfondi : délai de réservation, annulation et tarif journalier moyen (ADR).

## Jeu de données

- 119 390 réservations × 32 variables
- Période d'arrivée : juillet 2015 à août 2017
- Source : Antonio, N., de Almeida, A. et Nunes, L. (2019). *Hotel booking demand datasets*. Data in Brief, 22, 41–49. https://pmc.ncbi.nlm.nih.gov/articles/PMC6297060/

Le fichier `hotels.csv` n'est **pas** versionné (voir `.gitignore`). Pour reproduire l'analyse, télécharger le jeu de données depuis l'article ci-dessus, puis placer `hotels.csv` à la racine du projet.

## Contenu du dépôt

| Fichier | Description |
|---|---|
| `analyse_hotels.R` | Script complet (étapes 1 à 4) qui reproduit tableaux et figures |
| `rapport.pdf` | Rapport final (à ajouter au dépôt) |
| `figures/` | Figures générées par le script (créé à l'exécution) |
| `.gitignore` | Exclut les données brutes et les fichiers temporaires R |

## Reproduire l'analyse

Prérequis : R (≥ 4.1) et le package `tidyverse`.

```r
install.packages("tidyverse")
source("analyse_hotels.R")
```

## Questions explorées

1. Quels sont les délais de réservation habituels ?
2. Le tarif (ADR) varie-t-il selon le type d'hôtel ?
3. Le délai de réservation est-il associé à l'annulation ?
4. Le taux d'annulation diffère-t-il selon l'hôtel ?
5. Le tarif varie-t-il selon le mois d'arrivée ?

## Principaux constats

- Plus d'une réservation sur trois est annulée (37,04 %), nettement plus au City Hotel (41,73 %) qu'au Resort Hotel (27,76 %).
- Les réservations annulées sont faites bien plus tôt (médiane de 113 jours contre 45).
- Les tarifs montent en été (ADR moyen de 70,4 en janvier à 140,1 en août) ; l'ADR médian est plus élevé au City Hotel (99,9 contre 75,0).
- La relation linéaire entre délai et tarif est négligeable (r = −0,063).

Ces résultats sont descriptifs et ne prouvent pas de causalité.

## Limites

Les mois mélangent les deux hôtels et des années différentes ; des valeurs atypiques et des lignes identiques ont été conservées et signalées plutôt que supprimées. Voir le rapport pour le détail.

**Équipe :** Fatima Zohra Aboudeine - Safaa Naamane

