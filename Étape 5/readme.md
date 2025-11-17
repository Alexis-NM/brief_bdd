# 📈 5. Optimisation et analyse

## Créer des index sur les champs les plus sollicités

Pour améliorer les performances des requêtes sur les tables de production, plusieurs index ont été ajoutés sur les colonnes les plus sollicitées.  
Ces index accélèrent en particulier les recherches d’adresses, les jointures avec les communes et les voies, ainsi que les filtrages textuels.

Des index ont été créés sur :

- `adresse.code_insee` → accès rapide aux adresses d’une commune
- `adresse.id_fantoir` → jointure optimisée avec la table voie
- `voie.code_insee` → récupérations rapides des voies d’une commune

Ces index assurent une consultation fluide même lorsque le volume d’adresses augmente.

---

## Comparer les temps d’exécution avant et après indexation

#### Requêtes utilisées pour le test

Les temps proviennent de l’exécution répétée (avec `EXPLAIN ANALYZE`) des **requêtes représentatives** suivantes :

- Lister toutes les adresses d’une commune

```sql
EXPLAIN ANALYZE
SELECT a.id, a.numero, v.nom_voie
FROM adresse a
JOIN voie v ON a.id_fantoir = v.id_fantoir
WHERE a.code_insee = '01099';
```

- Compter les adresses par type de voie

```sql
EXPLAIN ANALYZE
SELECT
    c.nom_commune,
    UPPER(split_part(v.nom_voie, ' ', 1)) AS type_voie,
    COUNT(*) AS nb
FROM adresse a
JOIN voie v ON a.id_fantoir = v.id_fantoir
JOIN commune c ON a.code_insee = c.code_insee
GROUP BY c.nom_commune, type_voie;
```

- Recherche d’adresses par mot-clé

```sql
EXPLAIN ANALYZE
SELECT a.id, v.nom_voie
FROM adresse a
JOIN voie v ON a.id_fantoir = v.id_fantoir
WHERE v.nom_voie ILIKE '%rue%';
```

#### Résultats : avant / après indexation

| Test  | Requête                     | Avant         | Après        | Gain                 |
| ----- | --------------------------- | ------------- | ------------ | -------------------- |
| **1** | Sélection par commune       | **27.467 ms** | **0.274 ms** | **x100 plus rapide** |
| **2** | Agrégation par type de voie | **26.231 ms** | **8.445 ms** | **x3 plus rapide**   |
| **3** | Recherche par mot-clé       | **3.055 ms**  | **0.556 ms** | **x5 plus rapide**   |

#### Analyse

- L’index sur **adresse.code_insee** accélère énormément les requêtes de filtrage par commune.
- L’index sur **adress.id_fantoir** optimise efficacement les jointures voie ↔ adresse.
- L’index sur **voie.code_insee** améliore toutes les analyses groupées par commune.

---

## 📌 Optionnel : tester l’impact de la normalisation sur la taille et la lisibilité de la base

Pour évaluer les effets concrets de la normalisation sur la base de données, trois observations ont été menées :
(1) l’impact sur la taille des tables,
(2) la réduction des redondances,
(3) la lisibilité et la structure des données après transformation.

#### Taille des tables normalisées

Requête utilisée :

```sql
SELECT
    table_name,
    pg_size_pretty(pg_total_relation_size(table_name::regclass)) AS total_size
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY pg_total_relation_size(table_name::regclass) DESC;
```

Résultats :

| Table            | Taille  |
| ---------------- | ------- |
| adresse          | 49 MB   |
| voie             | 3160 kB |
| commune          | 96 kB   |
| position         | 24 kB   |
| ancienne_commune | 24 kB   |
| raw_adresses     | 16 kB   |

La normalisation concentre la volumétrie dans _adresse_, ce qui est
logique, et maintient des tables de référence très légères.

#### Réduction massive des redondances (exemple sur les voies)

Deux requêtes :

```sql
SELECT COUNT(DISTINCT nom_voie) AS voies_distinctes_raw FROM raw_adresses;
SELECT COUNT(*) AS voies_table FROM voie;
```

Résultats :

| Mesure                         | Valeur |
| ------------------------------ | ------ |
| Voies distinctes dans raw      | 1      |
| Voies dans la table normalisée | 21 642 |

Le champ voie brut est inutilisable (non distinct).\
La normalisation reconstruit 21 642 voies distinctes grâce au FANTOIR.

#### Répartition claire des adresses par commune

Requête :

```sql
SELECT c.code_insee, c.nom_commune, COUNT(a.id) AS nb_adresses
FROM commune c
JOIN adresse a ON a.code_insee = c.code_insee
GROUP BY c.code_insee, c.nom_commune
ORDER BY nb_adresses DESC;
```

Extrait :

| Commune         | Nb d’adresses |
| --------------- | ------------- |
| Bourg-en-Bresse | 8 557         |
| Oyonnax         | 6 011         |
| Valserhône      | 5 096         |
| …               | …             |

Les regroupements sont désormais propres, fiables et exploitables.
