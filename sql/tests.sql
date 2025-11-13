-- =====================
--  Tests de cohérence
-- =====================

-- 1) Vérifier que les tables normalisées ne sont pas vides
SELECT 
  (SELECT COUNT(*) FROM commune)          AS nb_communes,
  (SELECT COUNT(*) FROM voie)             AS nb_voies,
  (SELECT COUNT(*) FROM position)         AS nb_positions,
  (SELECT COUNT(*) FROM ancienne_commune) AS nb_anciennes_communes,
  (SELECT COUNT(*) FROM adresse)          AS nb_adresses;


-- 2) Vérifier l'unicité des identifiants d'adresse
SELECT 
    COUNT(*) AS nb_lignes,
    COUNT(DISTINCT id) AS nb_ids_distincts
FROM adresse;


-- 3) Vérifier les adresses sans rattachement à une commune
SELECT COUNT(*) AS nb_adresses_sans_commune
FROM adresse
WHERE code_insee IS NULL;