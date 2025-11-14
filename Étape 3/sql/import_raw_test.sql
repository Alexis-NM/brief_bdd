TRUNCATE TABLE raw_adresses;

\copy raw_adresses
FROM '/chemin/absolu/vers/le/fichier/data/raw_test.csv'
CSV HEADER DELIMITER ';' NULL '';