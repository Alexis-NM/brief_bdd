-- ============================
--  Création des tables
-- ============================

-- TABLE RAW (BRUTE)
CREATE TABLE raw_adresses (
    id TEXT,
    id_fantoir TEXT,
    numero TEXT,
    rep TEXT,
    nom_voie TEXT,
    code_postal TEXT,
    code_insee TEXT,
    nom_commune TEXT,
    code_insee_ancienne_commune TEXT,
    nom_ancienne_commune TEXT,
    x TEXT,
    y TEXT,
    lon TEXT,
    lat TEXT,
    type_position TEXT,
    alias TEXT,
    nom_ld TEXT,
    libelle_acheminement TEXT,
    nom_afnor TEXT,
    source_position TEXT,
    source_nom_voie TEXT,
    certification_commune TEXT,
    cad_parcelles TEXT
);

-- TABLE COMMUNE
CREATE TABLE commune (
    code_insee CHAR(5) PRIMARY KEY,
    nom_commune VARCHAR(100),
    code_postal CHAR(5),
    certification_commune BOOLEAN
);

-- TABLE POSITION
CREATE TABLE position (
    id_position SERIAL PRIMARY KEY,
    type_position VARCHAR(50) NOT NULL,
    source_position VARCHAR(50) NOT NULL
);

-- TABLE VOIE
CREATE TABLE voie (
    id_fantoir VARCHAR(12) PRIMARY KEY,
    nom_voie VARCHAR(150),
    nom_afnor VARCHAR(150),
    source_nom_voie VARCHAR(50),
    code_insee CHAR(5),
    CONSTRAINT fk_voie_commune
        FOREIGN KEY (code_insee)
        REFERENCES commune(code_insee)
);

-- TABLE ANCIENNE COMMUNE
CREATE TABLE ancienne_commune (
    code_insee_ancienne_commune CHAR(5) PRIMARY KEY,
    nom_ancienne_commune VARCHAR(100),
    code_insee CHAR(5),
    CONSTRAINT fk_ac_commune
        FOREIGN KEY (code_insee)
        REFERENCES commune(code_insee)
);

-- TABLE ADRESSE
CREATE TABLE adresse (
    id VARCHAR(30) PRIMARY KEY,
    numero SMALLINT,
    rep VARCHAR(5),
    alias VARCHAR(50),
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    cad_parcelles VARCHAR(255),
    code_insee CHAR(5),
    id_fantoir VARCHAR(12),
    id_position INTEGER,
    CONSTRAINT fk_adresse_commune
        FOREIGN KEY (code_insee)
        REFERENCES commune(code_insee),
    CONSTRAINT fk_adresse_voie
        FOREIGN KEY (id_fantoir)
        REFERENCES voie(id_fantoir),
    CONSTRAINT fk_adresse_position
        FOREIGN KEY (id_position)
        REFERENCES position(id_position)
);