-- ===========================================
-- INSERTION DES DONNÉES TRANSFORMÉES
-- ===========================================


-- 1) COMMUNE
INSERT INTO commune (code_insee, nom_commune, code_postal, certification_commune)
SELECT DISTINCT
    LEFT(TRIM(code_insee), 5)          AS code_insee,
    LEFT(TRIM(nom_commune), 100)       AS nom_commune,
    LEFT(TRIM(code_postal), 5)         AS code_postal,
    (certification_commune = '1')      AS certification_commune
FROM raw_adresses
WHERE code_insee IS NOT NULL
  AND TRIM(code_insee) <> ''
ON CONFLICT (code_insee) DO NOTHING;


-- 2) POSITION
INSERT INTO position (type_position, source_position)
SELECT type_position, source_position
FROM (
    SELECT DISTINCT
        LEFT(TRIM(type_position), 50)     AS type_position,
        LEFT(TRIM(source_position), 50)   AS source_position
    FROM raw_adresses
    WHERE (type_position IS NOT NULL AND TRIM(type_position) <> '')
       OR (source_position IS NOT NULL AND TRIM(source_position) <> '')
) AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM position p
    WHERE p.type_position = s.type_position
      AND p.source_position = s.source_position
);


-- 3) VOIE
INSERT INTO voie (id_fantoir, nom_voie, nom_afnor, source_nom_voie, code_insee)
SELECT DISTINCT
    LEFT(TRIM(id_fantoir), 12)        AS id_fantoir,
    LEFT(TRIM(nom_voie), 150)         AS nom_voie,
    LEFT(TRIM(nom_afnor), 150)        AS nom_afnor,
    LEFT(TRIM(source_nom_voie), 50)   AS source_nom_voie,
    LEFT(TRIM(code_insee), 5)         AS code_insee
FROM raw_adresses
WHERE id_fantoir IS NOT NULL
  AND TRIM(id_fantoir) <> ''
ON CONFLICT (id_fantoir) DO NOTHING;


-- 4) ANCIENNE COMMUNE
INSERT INTO ancienne_commune (code_insee_ancienne_commune, nom_ancienne_commune, code_insee)
SELECT DISTINCT
    LEFT(TRIM(code_insee_ancienne_commune), 5)  AS code_insee_ancienne_commune,
    LEFT(TRIM(nom_ancienne_commune), 100)       AS nom_ancienne_commune,
    LEFT(TRIM(code_insee), 5)                   AS code_insee
FROM raw_adresses
WHERE code_insee_ancienne_commune IS NOT NULL
  AND TRIM(code_insee_ancienne_commune) <> ''
ON CONFLICT (code_insee_ancienne_commune) DO NOTHING;


-- 5) ADRESSE
INSERT INTO adresse (
    id, numero, rep, alias, x, y, lon, lat, cad_parcelles,
    code_insee, id_fantoir, id_position
)
SELECT
    LEFT(TRIM(r.id), 30)                      AS id,
    NULLIF(TRIM(r.numero), '')::SMALLINT     AS numero,
    LEFT(TRIM(r.rep), 5)                     AS rep,
    LEFT(TRIM(r.alias), 50)                  AS alias,
    NULLIF(TRIM(r.x), '')::DOUBLE PRECISION  AS x,
    NULLIF(TRIM(r.y), '')::DOUBLE PRECISION  AS y,
    NULLIF(TRIM(r.lon), '')::DOUBLE PRECISION AS lon,
    NULLIF(TRIM(r.lat), '')::DOUBLE PRECISION AS lat,
    LEFT(TRIM(r.cad_parcelles), 255)         AS cad_parcelles,

    LEFT(TRIM(r.code_insee), 5)              AS code_insee,
    NULLIF(LEFT(TRIM(r.id_fantoir), 12), '') AS id_fantoir,
    p.id_position
FROM raw_adresses r
LEFT JOIN position p
    ON p.type_position   = LEFT(TRIM(r.type_position), 50)
   AND p.source_position = LEFT(TRIM(r.source_position), 50)
WHERE TRIM(r.id) <> ''
ON CONFLICT (id) DO NOTHING;