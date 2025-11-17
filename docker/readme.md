# 🐳 Lancement de la base de donnée avec Docker

Ce repo inclut un fichier `/docker/docker-compose.yml` permettant de lancer rapidement l'instance PostgreSQL dans Docker.

---

## 📦 1. Démarrer le service PostgreSQL

Depuis le dossier **docker** (où se trouve `docker-compose.yml`), exécuter :

```bash
docker compose up -d
```

Cette commande :

- télécharge l’image PostgreSQL (la première fois uniquement),
- démarre une base de données isolée,
- crée un volume `postgres-data` pour la persistance des données,
- expose PostgreSQL localement sur le port `5432`.

---

## 🧩 2. Connexion à la base

Une fois le conteneur démarré on peut se connecter à la base sur DBeaver avec les paramètres suivants :

- **Host** : `localhost`  
- **Port** : `5432`  
- **Database** : `data_gouv`  
- **User** : `alexis`  
- **Password** : `password`

---

## 🔍 3. Vérifier que le conteneur tourne

```bash
docker ps
```

---

## 🛑 4. Arrêter PostgreSQL

```bash
docker compose down
```

---

## 🔄 5. Redémarrage

```bash
docker compose up -d
```

---

## 🧹 6. Réinitialisation complète

Pour repartir d’une instance vide :

```bash
docker compose down -v
```

Cette commande supprime également le volume `postgres-data`.