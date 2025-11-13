# 🧭 Brief — Base Adresses Nationales
**Optimisation et modélisation de données réelles**

---

## 🎯 Objectif

À partir d’une source de données officielle volumineuse (Base Adresse Nationale), concevoir, structurer et optimiser une base de données relationnelle cohérente et performante.

Vous allez :

- Importer et analyser un jeu de données réel en PostgreSQL.
- Concevoir un modèle MERISE complet (MCD, MLD, MPD).
- Normaliser et indexer la base pour améliorer sa qualité et ses performances.
- Écrire des requêtes SQL avancées, procédures stockées et triggers.
- Documenter l’ensemble de la démarche et des choix réalisés.

---

## 🧩 Contexte

Les adresses sont partout : livraison, services publics, GPS, applications mobiles…  
Mais derrière ce concept simple se cache une grande complexité : une adresse dépend d’une commune, d’un code postal, d’une voie, d’un numéro, et parfois de multiples sources de référence.

La Base Adresse Nationale (BAN) est la **golden source** des adresses françaises.  
Elle contient plus de 26 millions d’enregistrements, disponibles au format CSV sur :  
[https://adresse.data.gouv.fr/data/ban/adresses/latest/csv/](https://adresse.data.gouv.fr/data/ban/adresses/latest/csv/)

---

## ⚙️ Étapes du projet

### 1. Découverte de la donnée
- Télécharger un fichier CSV départemental (ex. adresses-59.csv).  
- Explorer les colonnes, types de données, doublons, valeurs manquantes.  
- Importer le fichier dans PostgreSQL dans une **table brute**.  
- Identifier les entités logiques et relations potentielles.  

### 2. Modélisation MERISE
- Construire le **MCD** (identification des entités et relations).  
- Formaliser les règles de gestion et le dictionnaire de données.  
- Préciser les contraintes (unicité, cardinalités, dépendances fonctionnelles).  
- Décliner ensuite le **MLD et le MPD**.  

### 3. Mise en place de la base
- Créer les tables issues du MPD.  
- Insérer un jeu d’échantillon issu du CSV pour les tests.  
- Écrire un **script SQL** qui transforme les données brutes vers le nouveau modèle normalisé, pour pouvoir réexécuter facilement le processus avec un autre fichier.  
- Vérifier cohérence et normalisation.  

### 4. Requêtes SQL à produire

#### 4.1 Requêtes de consultation
- Lister toutes les adresses d’une **commune donnée**, triées par numéro de voie.  
- Compter le nombre d’adresses par **commune** et par **type de voie**.  
- Lister toutes les **communes distinctes** présentes dans le fichier.  
- Rechercher toutes les adresses contenant un **mot-clé** dans le nom de voie.  
- Trouver toutes les adresses où le **code postal ne correspond pas à la commune**.  

#### 4.2 Requêtes d’insertion / mise à jour / suppression
- Ajouter une nouvelle adresse complète dans les tables finales.  
- Mettre à jour le nom d’une voie pour une adresse spécifique.  
- Supprimer toutes les adresses avec un **champ manquant critique** (ex : numéro de voie vide).  

#### 4.3 Détection de problèmes et qualité des données
- Identifier **doublons exacts** (mêmes numéro + nom de voie + code postal + commune).  
- Identifier les **adresses incohérentes**, par exemple coordonnées GPS absentes ou en dehors du département.  
- Lister les codes postaux avec plus de 10 000 adresses pour détecter les anomalies volumétriques.  

#### 4.4 Requêtes d’agrégation et analyse
- Nombre moyen d’adresses par commune et par type de voie.  
- Top 10 des communes avec le plus d’adresses.  
- Vérifier la **complétude des champs essentiels** (numéro, voie, code postal, commune).  

#### 4.5 Requêtes avancées
- Créer une **procédure stockée** pour insérer ou mettre à jour une adresse selon qu’elle existe déjà.  
- Créer un **trigger** qui vérifie, avant insertion, que les coordonnées GPS sont valides et que le code postal correspond à la commune.  
- Ajouter automatiquement une **date de création / mise à jour** à chaque modification via trigger.  

---

### 5. Optimisation et analyse
- Créer des **index** sur les champs les plus sollicités.  
- Comparer les temps d’exécution avant et après indexation.  
- Optionnel : tester l’impact de la normalisation sur la taille et la lisibilité de la base.  

---

## 📦 Livrables
- Le **dictionnaire de données** et les règles de gestion.  
- Le **MCD, MLD, MPD** (en image ou PDF).  
- Le **script SQL complet** :
  - création des tables,
  - insertion d’un jeu d’essai,
  - transformation des données brutes vers le modèle normalisé,
  - requêtes demandées,
  - procédure stockée,
  - trigger.  
- Un fichier **docker-compose.yml** pour PostgreSQL.  
- Un fichier **README.md** détaillant :
  - étapes d’installation,
  - choix de modélisation,
  - exemples de requêtes,
  - observations de performance.  

---

## ✅ Critères de performance
| Critère | Validation |
|---------|------------|
| Import du CSV réussi |  |
| MCD / MLD / MPD cohérents |  |
| Données normalisées |  |
| Procédure stockée fonctionnelle |  |
| Trigger fonctionnel |  |
| Requêtes SQL correctes et testées | |
| Index créés et justifiés |  |
| Documentation claire et structurée |  |
| Projet exécutable via Docker | |

---

## 🧠 Ressources
- [Base Adresse Nationale (BAN)](https://adresse.data.gouv.fr/data/ban/adresses/latest/csv/)  
- [Documentation PostgreSQL](https://www.postgresql.org/docs/)  
- [DBeaver Community](https://dbeaver.io/download/)  
- [Méthode MERISE – Résumé](https://fr.wikipedia.org/wiki/Merise)  
- [Docker Compose Postgres Exemple](https://docs.docker.com/compose/compose-file/compose-file-v3/#postgresql)
