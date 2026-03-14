Raspberry Pi — Setup & Flask

Ce dépôt permet de configurer automatiquement un Raspberry Pi from scratch :
mettre à jour le système, installer Python, créer un environnement virtuel et lancer un serveur Flask.

 Utilisation

```bash
# 1. Configuration du système
sudo bash main.sh

# 2. Lancement du serveur Flask
sudo bash run_flask.sh
```

Ce que ça fait

1. **Mise à jour** du système via `apt`
2. **Installation** de Python3 et pip
3. **Création** d'un environnement virtuel et installation des dépendances
4. **Lancement** du serveur Flask
