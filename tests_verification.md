## 🧪 d. Vérification de la cohérence et de la normalisation

Une fois la transformation effectuée, plusieurs contrôles permettent de valider la qualité du modèle et la bonne cohérence des données insérées dans les tables normalisées.

Les requêtes suivantes constituent un jeu de tests minimal et suffisant.

---

### ✔️ 1. Vérifier que les tables normalisées ont bien été remplies

```sql
SELECT 
  (SELECT COUNT(*) FROM commune)          AS nb_communes,
  (SELECT COUNT(*) FROM voie)             AS nb_voies,
  (SELECT COUNT(*) FROM position)         AS nb_positions,
  (SELECT COUNT(*) FROM ancienne_commune) AS nb_anciennes_communes,
  (SELECT COUNT(*) FROM adresse)          AS nb_adresses;
```

---

### ✔️ 2. Vérifier l’unicité des identifiants d’adresse

```sql
SELECT 
    COUNT(*) AS nb_lignes,
    COUNT(DISTINCT id) AS nb_ids_distincts
FROM adresse;
```

---

### ✔️ 3. Vérifier que toutes les adresses sont rattachées à une commune

```sql
SELECT COUNT(*) AS nb_adresses_sans_commune
FROM adresse
WHERE code_insee IS NULL;
```

---

### ✔️ 4. Vérifier que toutes les voies sont rattachées à une commune

```sql
SELECT COUNT(*) AS nb_voies_sans_commune
FROM voie v
LEFT JOIN commune c ON v.code_insee = c.code_insee
WHERE c.code_insee IS NULL;
```

---

### ✔️ 5. Vérifier les adresses sans position

```sql
SELECT COUNT(*) AS nb_adresses_sans_position
FROM adresse
WHERE id_position IS NULL;
```

---

### ✔️ 6. Vérifier l’absence de doublons dans les identifiants d’adresse

```sql
SELECT id, COUNT(*) AS occurrences
FROM adresse
GROUP BY id
HAVING COUNT(*) > 1;
```
