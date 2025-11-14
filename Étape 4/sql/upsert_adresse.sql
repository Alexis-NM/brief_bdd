CREATE OR REPLACE FUNCTION upsert_adresse(
    p_id               TEXT,
    p_numero           INTEGER,
    p_rep              TEXT,
    p_alias            TEXT,
    p_x                DOUBLE PRECISION,
    p_y                DOUBLE PRECISION,
    p_lon              DOUBLE PRECISION,
    p_lat              DOUBLE PRECISION,
    p_cad_parcelles    TEXT,
    p_code_insee       TEXT,
    p_id_fantoir       TEXT,
    p_nom_voie         TEXT,
    p_nom_afnor        TEXT,
    p_source_nom_voie  TEXT,
    p_type_position    TEXT,
    p_source_position  TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_position INTEGER;
    v_id_fantoir_clean VARCHAR(12);
    v_code_insee_clean CHAR(5);
BEGIN

    v_id_fantoir_clean := LEFT(TRIM(p_id_fantoir), 12);
    v_code_insee_clean := LEFT(TRIM(p_code_insee), 5);

    INSERT INTO voie (id_fantoir, nom_voie, nom_afnor, source_nom_voie, code_insee)
    VALUES (
        v_id_fantoir_clean,
        LEFT(TRIM(p_nom_voie), 150),
        LEFT(COALESCE(TRIM(p_nom_afnor), TRIM(p_nom_voie)), 150),
        LEFT(COALESCE(TRIM(p_source_nom_voie), 'inconnue'), 50),
        v_code_insee_clean
    )
    ON CONFLICT (id_fantoir) DO UPDATE
    SET
        nom_voie       = EXCLUDED.nom_voie,
        nom_afnor      = EXCLUDED.nom_afnor,
        source_nom_voie = EXCLUDED.source_nom_voie,
        code_insee     = EXCLUDED.code_insee;


    INSERT INTO position (type_position, source_position)
    SELECT p_type_position, p_source_position
    WHERE NOT EXISTS (
        SELECT 1
        FROM position
        WHERE type_position = p_type_position
          AND source_position = p_source_position
    );

    SELECT id_position INTO v_id_position
    FROM position
    WHERE type_position = p_type_position
      AND source_position = p_source_position;


    INSERT INTO adresse (
        id, numero, rep, alias,
        x, y, lon, lat,
        cad_parcelles,
        code_insee, id_fantoir, id_position
    )
    VALUES (
        LEFT(TRIM(p_id), 30),
        p_numero::SMALLINT,
        p_rep,
        p_alias,
        p_x,
        p_y,
        p_lon,
        p_lat,
        p_cad_parcelles,
        v_code_insee_clean,
        v_id_fantoir_clean,
        v_id_position
    )
    ON CONFLICT (id) DO UPDATE
    SET
        numero        = EXCLUDED.numero,
        rep           = EXCLUDED.rep,
        alias         = EXCLUDED.alias,
        x             = EXCLUDED.x,
        y             = EXCLUDED.y,
        lon           = EXCLUDED.lon,
        lat           = EXCLUDED.lat,
        cad_parcelles = EXCLUDED.cad_parcelles,
        code_insee    = EXCLUDED.code_insee,
        id_fantoir    = EXCLUDED.id_fantoir,
        id_position   = EXCLUDED.id_position;
END;
$$;