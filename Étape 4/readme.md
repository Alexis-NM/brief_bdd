# 📙 4. Requêtes SQL à produire

## 🔍 4.1 Requêtes de consultation

#### Lister toutes les adresses d’une commune donnée, triées par numéro de voie

```
SELECT
    a.id,
    a.numero,
    a.rep,
    v.nom_voie,
    c.nom_commune,
    c.code_postal
FROM adresse a
JOIN commune c ON a.code_insee = c.code_insee
LEFT JOIN voie v ON a.id_fantoir = v.id_fantoir
WHERE c.code_insee = '01004'
ORDER BY v.nom_voie, a.numero, a.rep;
```

#### Compter le nombre d’adresses par commune et par type de voie

```
WITH voies_typées AS (
    SELECT
        c.code_insee,
        c.nom_commune,
        UPPER(split_part(v.nom_voie, ' ', 1)) AS type_voie
    FROM adresse a
    JOIN commune c ON a.code_insee = c.code_insee
    JOIN voie v ON a.id_fantoir = v.id_fantoir
)
SELECT
    code_insee,
    nom_commune,
    type_voie,
    COUNT(*) AS nb_adresses
FROM voies_typées
WHERE type_voie IN (
    'ALLEE','AVENUE','BOULEVARD','CHEMIN','CITE','CLOS','COUR',
    'CHAUSSEE','DOMAINE','DESCENTE','ESPACE','ESPLANADE','GRANDE',
    'IMPASSE','LIEU-DIT','LOTISSEMENT','PASSAGE','PLACE','PLAINE',
    'PLATEAU','PROMENADE','QUAI','ROND-POINT','ROUTE','RUE',
    'SENTE','SENTIER','SQUARE','TRAVERSE','VILLA','VOIE'
)
GROUP BY code_insee, nom_commune, type_voie
ORDER BY nom_commune, type_voie;
```

#### Lister toutes les communes distinctes présentes dans le fichier

```
SELECT
    c.code_insee,
    c.nom_commune,
    c.code_postal
FROM commune c
ORDER BY c.nom_commune;
```

#### Rechercher toutes les adresses contenant un mot-clé dans le nom de voie

```
SELECT
    a.id,
    a.numero,
    a.rep,
    v.nom_voie,
    c.nom_commune,
    c.code_postal
FROM adresse a
JOIN voie v ON a.id_fantoir = v.id_fantoir
JOIN commune c ON a.code_insee = c.code_insee
WHERE v.nom_voie ILIKE '%charles%'
ORDER BY c.nom_commune, v.nom_voie, a.numero;
```

#### Trouver toutes les adresses où le code postal ne correspond pas à la commune

Dans le modèle normalisé, chaque commune possède obligatoirement un code postal (table commune).
La vérification compare le code postal brut du CSV avec le code postal normalisé de la commune.

```
SELECT
    r.id,
    r.nom_voie,
    r.numero,
    r.code_postal AS code_postal_raw,
    c.code_postal AS code_postal_normalise,
    c.nom_commune
FROM raw_adresses r
JOIN adresse a ON a.id = r.id
JOIN commune c ON a.code_insee = c.code_insee
WHERE TRIM(r.code_postal) <> TRIM(c.code_postal)
      AND TRIM(r.code_postal) <> ''
      AND TRIM(c.code_postal) <> '';
```

## 📋 4.2 Requêtes d’insertion / mise à jour / suppression

#### Ajouter une nouvelle adresse complète dans les tables finales

```
INSERT INTO commune (code_insee, nom_commune, code_postal, certification_commune)
VALUES ('01099', 'Ville-Exemple', '01234', TRUE)
ON CONFLICT (code_insee) DO NOTHING;

INSERT INTO voie (id_fantoir, nom_voie, nom_afnor, source_nom_voie, code_insee)
VALUES ('01099A123', 'Rue Exemple', 'RUE EXEMPLE', 'commune', '01099')
ON CONFLICT (id_fantoir) DO NOTHING;

INSERT INTO position (type_position, source_position)
SELECT 'entrée', 'commune'
WHERE NOT EXISTS (
    SELECT 1 FROM position
    WHERE type_position = 'entrée'
      AND source_position = 'commune'
);
WITH pos AS (
    SELECT id_position
    FROM position
    WHERE type_position = 'entrée'
      AND source_position = 'commune'
)

INSERT INTO adresse (
    id, numero, rep, alias, x, y, lon, lat, cad_parcelles,
    code_insee, id_fantoir, id_position
)
SELECT
    '01099_test_00001', 12, NULL, NULL, 883000.12, 6543000.45,
    5.234123, 45.934567, '01099000AB1234',
    '01099', '01099A123', pos.id_position
FROM pos
ON CONFLICT (id) DO NOTHING;
```

#### Mettre à jour le nom d’une voie pour une adresse spécifique

```
UPDATE voie
SET nom_voie = 'Rue du Test',
    nom_afnor = 'RUE DU TEST'
WHERE id_fantoir = (
    SELECT id_fantoir
    FROM adresse
    WHERE id = '01099_test_00001'
);
```

#### Supprimer toutes les adresses avec un champ manquant critique (ex : numéro de voie vide)

```
DELETE FROM adresse
WHERE numero IS NULL
   OR code_insee IS NULL
   OR id_fantoir IS NULL;
```

## 🛟 4.3 Détection de problèmes et qualité des données

#### Identifier doublons exacts (mêmes numéro + nom de voie + code postal + commune)

```
SELECT
    c.code_postal,
    c.nom_commune,
    v.nom_voie,
    a.numero,
    COUNT(*) AS nb_occurrences
FROM adresse a
JOIN voie v     ON a.id_fantoir = v.id_fantoir
JOIN commune c  ON a.code_insee = c.code_insee
GROUP BY
    c.code_postal,
    c.nom_commune,
    v.nom_voie,
    a.numero
HAVING COUNT(*) > 1
ORDER BY nb_occurrences DESC, c.nom_commune, v.nom_voie, a.numero;
```

#### Identifier les adresses incohérentes, par exemple coordonnées GPS absentes ou en dehors du département

```
SELECT
    a.id,
    a.numero,
    v.nom_voie,
    c.nom_commune,
    a.lon,
    a.lat
FROM adresse a
JOIN commune c ON a.code_insee = c.code_insee
LEFT JOIN voie v ON a.id_fantoir = v.id_fantoir
WHERE
      a.lon IS NULL
   OR a.lat IS NULL
   OR a.lon NOT BETWEEN -180 AND 180
   OR a.lat NOT BETWEEN -90 AND 90
ORDER BY c.nom_commune, v.nom_voie, a.numero;
```

#### Lister les codes postaux avec plus de 10 000 adresses pour détecter les anomalies volumétriques

```
SELECT
    c.code_postal,
    c.nom_commune,
    COUNT(*) AS nb_adresses
FROM adresse a
JOIN commune c ON a.code_insee = c.code_insee
GROUP BY c.code_postal, c.nom_commune
HAVING COUNT(*) > 10000
ORDER BY nb_adresses DESC;
```

## 🧪 4.4 Requêtes d’agrégation et analyse

#### Nombre moyen d’adresses par commune et par type de voie

```

```

#### Top 10 des communes avec le plus d’adresses

```

```

#### Vérifier la complétude des champs essentiels (numéro, voie, code postal, commune)

```

```

## 📡 4.5 Requêtes avancées

#### Créer une procédure stockée pour insérer ou mettre à jour une adresse selon qu’elle existe déjà

```

```

#### Créer un trigger qui vérifie, avant insertion, que les coordonnées GPS sont valides et que le code postal correspond à la commune

```

```

#### Ajouter automatiquement une date de création / mise à jour à chaque modification via trigger

```

```
