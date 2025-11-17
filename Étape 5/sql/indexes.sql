-- ==========================================
--  INDEXES POUR OPTIMISER LES PERFORMANCES
-- ==========================================

-- ========== Table ADRESSE ==========
CREATE INDEX IF NOT EXISTS idx_adresse_code_insee
    ON adresse(code_insee);

CREATE INDEX IF NOT EXISTS idx_adresse_id_fantoir
    ON adresse(id_fantoir);

-- ========== Table VOIE ==========
CREATE INDEX IF NOT EXISTS idx_voie_code_insee
    ON voie(code_insee);