# 🖥️ 1. Découverte de la donnée

## Télécharger un fichier CSV départemental (ex. adresses-59.csv)

Fichier téléchargé et présent dans `../data/adresses-01.csv`

---

## Explorer les colonnes, types de données, doublons, valeurs manquantes

Dès l’exploration du fichier CSV brut, on observe un grand nombre de colonnes hétérogènes, mélangeant identifiants, informations géographiques, libellés textuels et métadonnées techniques.
L’analyse préliminaire révèle également des doublons, des valeurs manquantes et des incohérences (ex. codes postaux vides, types de voies irréguliers), confirmant la nécessité d’un travail de normalisation avant toute exploitation fiable.

---

## Importer le fichier dans PostgreSQL dans une table brute

Voir la capture d'écran DBeaver :

![Screenshot](../screenshots/screenshot-1.png)

---

## Identifier les entités logiques et relations potentielles

**Étape 1 — Analyse des colonnes**

| **Colonne**                 | **Signification probable**                     | **Type logique**     |
| --------------------------- | ---------------------------------------------- | -------------------- |
| id                          | Identifiant unique de l’adresse                | Identifiant          |
| id_fantoir                  | Code FANTOIR de la voie (identifiant national) | Référence voie       |
| numero                      | Numéro dans la rue                             | Numérique            |
| rep                         | Répétition (bis, ter, etc.)                    | Texte court          |
| nom_voie                    | Nom de la voie                                 | Texte                |
| code_postal                 | Code postal                                    | Texte ou entier      |
| code_insee                  | Code INSEE de la commune                       | Référence commune    |
| nom_commune                 | Nom de la commune                              | Texte                |
| code_insee_ancienne_commune | Code INSEE avant fusion (si applicable)        | Texte                |
| nom_ancienne_commune        | Nom de l’ancienne commune                      | Texte                |
| x, y                        | Coordonnées projetées (ex: Lambert 93)         | Nombre               |
| lon, lat                    | Coordonnées GPS                                | Nombre               |
| type_position               | Type de position (entrée, bâtiment, etc.)      | Texte                |
| alias                       | Nom alternatif                                 | Texte                |
| nom_ld                      | Lieu-dit                                       | Texte                |
| libelle_acheminement        | Libellé postal                                 | Texte                |
| nom_afnor                   | Nom normalisé (AFNOR)                          | Texte                |
| source_position             | Origine de la position                         | Texte                |
| source_nom_voie             | Origine du nom de voie                         | Texte                |
| certification_commune       | Niveau de validation par la commune            | Booléen ou numérique |
| cad_parcelles               | Liste de parcelles cadastrales liées           | Texte long           |

**Étape 2 — Groupement en entités**

| **Entité**           | **Attributs clés**                                                   | **Commentaire**                  |
| -------------------- | -------------------------------------------------------------------- | -------------------------------- |
| **Adresse**          | id, numero, rep, type_position, alias, x, y, lon, lat, cad_parcelles | Donnée principale (localisation) |
| **Voie**             | id_fantoir, nom_voie, nom_afnor, source_nom_voie                     | Répertoire des rues              |
| **Commune**          | code_insee, nom_commune, code_postal, certification_commune          | Regroupe les adresses            |
| **Ancienne commune** | code_insee_ancienne_commune, nom_ancienne_commune                    | Historique administratif         |
| **Position**         | type_position, source_position                                       | Métadonnées sur la position      |
