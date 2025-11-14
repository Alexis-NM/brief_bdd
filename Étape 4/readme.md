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

#### Identifier les adresses où le code postal est vide alors que la commune est renseignée

Dans le modèle normalisé, chaque commune doit disposer d’un code postal renseigné.
La vérification consiste donc à identifier les adresses où la commune est présente mais le code postal est manquant ou vide, ce qui indique une anomalie dans les données source.

```
SELECT
    a.id,
    a.numero,
    v.nom_voie,
    c.nom_commune,
    c.code_postal
FROM adresse a
JOIN commune c ON a.code_insee = c.code_insee
LEFT JOIN voie v ON a.id_fantoir = v.id_fantoir
WHERE
    (c.code_postal IS NULL OR TRIM(c.code_postal) = '')
    AND c.nom_commune IS NOT NULL
    AND TRIM(c.nom_commune) <> '';
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

#### Identifier les adresses incohérentes sans coordonnées GPS

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
    OR TRIM(a.lon::TEXT) = ''
    OR TRIM(a.lat::TEXT) = ''
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

#### Nombre moyen d’adresses par commune et par voie

```
WITH types_normaux AS (
    SELECT UNNEST(ARRAY[
        'RUE', 'AVENUE', 'AV', 'BD', 'BOULEVARD', 'CHEMIN', 'CH',
        'IMPASSE', 'PLACE', 'ROUTE', 'ALLEE', 'ALLEES', 'QUAI',
        'CITE', 'COUR', 'PASSAGE', 'SQUARE', 'VOIE', 'PROMENADE',
        'BOIS', 'CLOS', 'SENTIER', 'TRAVERSE', 'ESPLANADE',
        'FAUBOURG', 'FG', 'GRANDE RUE', 'HAMEAU', 'LOTISSEMENT',
        'MARCHE', 'PARC', 'RESIDENCE', 'ROND-POINT', 'RP'
    ]) AS type_voie
),

adresses_par_commune_et_type AS (
    SELECT
        c.code_insee,
        c.nom_commune,
        t.type_voie,
        COUNT(*) AS nb_adresses
    FROM adresse a
    JOIN commune c ON a.code_insee = c.code_insee
    JOIN voie v    ON a.id_fantoir = v.id_fantoir
    LEFT JOIN types_normaux t
        ON UPPER(split_part(v.nom_voie, ' ', 1)) = t.type_voie
    WHERE t.type_voie IS NOT NULL
    GROUP BY
        c.code_insee,
        c.nom_commune,
        t.type_voie
)

SELECT
    type_voie,
    AVG(nb_adresses)::NUMERIC(10,2) AS nb_moyen_adresses_par_commune
FROM adresses_par_commune_et_type
GROUP BY type_voie
ORDER BY nb_moyen_adresses_par_commune DESC;
```

#### Top 10 des communes avec le plus d’adresses

```
SELECT
    c.code_insee,
    c.nom_commune,
    c.code_postal,
    COUNT(*) AS nb_adresses
FROM adresse a
JOIN commune c ON a.code_insee = c.code_insee
GROUP BY
    c.code_insee,
    c.nom_commune,
    c.code_postal
ORDER BY nb_adresses DESC
LIMIT 10;
```

#### Vérifier la complétude des champs essentiels (numéro, voie, code postal, commune)

```
SELECT
    COUNT(*) AS nb_total_adresses,

    COUNT(a.numero) AS nb_numero_non_null,
    COUNT(*) - COUNT(a.numero) AS nb_numero_manquant,

    COUNT(v.nom_voie) AS nb_nom_voie_non_null,
    COUNT(*) - COUNT(v.nom_voie) AS nb_nom_voie_manquant,

    COUNT(c.code_postal) AS nb_code_postal_non_null,
    COUNT(*) - COUNT(c.code_postal) AS nb_code_postal_manquant,

    COUNT(c.nom_commune) AS nb_nom_commune_non_null,
    COUNT(*) - COUNT(c.nom_commune) AS nb_nom_commune_manquant
FROM adresse a
LEFT JOIN voie v    ON a.id_fantoir = v.id_fantoir
LEFT JOIN commune c ON a.code_insee = c.code_insee;
```

## 📡 4.5 Requêtes avancées

#### Créer une procédure stockée pour insérer ou mettre à jour une adresse selon qu’elle existe déjà

L’objectif est de disposer d’un mécanisme unique pour créer ou modifier une adresse, sans dupliquer la logique SQL dans les scripts ou dans l’application.
Ce comportement, appelé UPSERT (combinaison d’INSERT et d’UPDATE), permet de garder les données cohérentes tout en simplifiant l’utilisation de la base.

La procédure stockée est définie dans le script : `./sql/upsert_adresse.sql`

C'est donc un bloc de logique SQL centralisé dans la base, que l’on peut réutiliser simplement via : `SELECT upsert_adresse(...);`

Si on regarde la fonction plus en détail on constate qu'elle encapsule toute la logique d’ajout / mise à jour d’une adresse dans le modèle normalisé.

Dans un premier temps, elle garantit l'existence de la voie (voie) à partir de l’id_fantoir, du nom de voie et de sa source (UPSERT sur voie). Ainsi que l’existence de la position (position) à partir du couple (type_position, source_position) (insert si nécessaire, sinon réutilisation).

Elle effectue ensuite un UPSERT sur la table `adresse` : si l'identifiant n'existe pas, l'enregistrement est inséré ; sinon, il est mis à jour avec les nouvelles valeurs.

Pour utiliser cette fonction, on l’appelle en lui passant toutes les informations nécessaires à la description de l’adresse, de la voie et de la position associée :

```
SELECT upsert_adresse(
    '<ID_ADRESSE>',
    <NUMERO>,
    '<REP>',
    '<ALIAS>',
    <X>,
    <Y>,
    <LON>,
    <LAT>,
    '<CAD_PAR_CELLES>',
    '<CODE_INSEE>',
    '<ID_FANTOIR>',
    '<NOM_VOIE>',
    '<NOM_AFNOR>',
    '<SOURCE_NOM_VOIE>',
    '<TYPE_POSITION>',
    '<SOURCE_POSITION>'
);
```

#### Créer un trigger qui vérifie, avant insertion, que les coordonnées GPS sont valides et que le code postal correspond à la commune

Pour garantir la qualité des données au moment de leur insertion, un trigger de validation a été mis en place sur la table adresse.
Ce mécanisme s’exécute automatiquement avant chaque insertion ou mise à jour et contrôle deux éléments essentiels :

- la cohérence du code postal
- la validité des coordonnées GPS

D’abord, le trigger vérifie que le code_insee fourni pour l’adresse correspond bien à une commune existante, puis récupère son code postal. Celui-ci doit impérativement respecter le format « 5 chiffres ». Toute incohérence entre l’adresse et sa commune entraîne le rejet immédiat de l’opération.

Ensuite, le trigger contrôle les coordonnées géographiques : la latitude doit être comprise entre –90 et +90, et la longitude entre –180 et +180. Ces bornes permettent d’écarter les erreurs de saisie ou de conversion.

L’ensemble de cette logique est défini dans le script `./sql/trg_validate_adresse.sql`

#### Ajouter automatiquement une date de création / mise à jour à chaque modification via trigger

Pour assurer un suivi fiable de l’évolution des données, un trigger dédié gère automatiquement les champs date_creation et date_mise_a_jour de la table adresse.
Lors d’une insertion, le trigger initialise date_creation à la date courante, puis positionne date_mise_a_jour à la même valeur.
Lors d’une mise à jour, date_creation est conservée tandis que date_mise_a_jour est actualisée automatiquement.

Ce mécanisme garantit une traçabilité complète sans intervention de l’application ni risque d’oubli.

Le trigger est défini dans le script : `./sql/trg_timestamps_adresse.sql`
