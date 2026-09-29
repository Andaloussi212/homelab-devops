# Homelab DevOps

[![Validation Homelab](https://github.com/Andaloussi212/homelab-devops/actions/workflows/ci.yml/badge.svg)](https://github.com/Andaloussi212/homelab-devops/actions/workflows/ci.yml)

Homelab personnel basé sur un Raspberry Pi sous Debian.

L'objectif de ce projet est de mettre en pratique des compétences en administration Linux, conteneurisation, réseau, automatisation, supervision et sécurité.

## Infrastructure actuelle

- Raspberry Pi
- Debian 13 ARM64
- Docker
- Docker Compose
- Caddy
- Nextcloud
- MariaDB
- Redis
- Tailscale
- HTTPS automatique

## Services

### Portfolio

Portfolio personnel hébergé sur le Raspberry Pi et exposé avec Caddy.

- Reverse proxy : Caddy
- HTTPS automatique
- Domaine personnel
- Déploiement via Docker Compose

### Nextcloud

Instance Nextcloud auto-hébergée avec Docker Compose.

Stack utilisée :

- Nextcloud
- MariaDB
- Redis
- Docker Compose

## Architecture

```text
Internet
   |
   v
Caddy
   |
   +----------------------+
   |                      |
   v                      v
Portfolio              Nextcloud
                         |
                  +------+------+
                  |             |
               MariaDB        Redis
```

## Accès et réseau

L'administration du Raspberry Pi peut être effectuée à distance via Tailscale.

Cela permet d'accéder au serveur sans exposer directement l'administration SSH sur Internet.

Caddy gère l'accès HTTP/HTTPS aux différents services et les certificats TLS.

## Technologies utilisées

- Linux
- Debian
- Docker
- Docker Compose
- Caddy
- Nextcloud
- MariaDB
- Redis
- Tailscale
- Git
- Bash

## Roadmap

- [x] Déploiement de services avec Docker
- [x] Gestion des services avec Docker Compose
- [x] Reverse proxy avec Caddy
- [x] HTTPS automatique
- [x] Accès distant avec Tailscale
- [x] Sauvegardes automatisées
- [ ] Monitoring avec Prometheus
- [ ] Dashboards Grafana
- [ ] Supervision de disponibilité
- [x] Automatisation avec Ansible
- [x] CI avec GitHub Action
- [x] CD avec self-hosted runner
- [ ] Infrastructure as Code
- [ ] Hardening Linux
- [ ] Documentation des incidents
- [ ] Centralisation des logs

## Objectifs du projet

Ce projet me permet de construire et d'administrer une infrastructure auto-hébergée proche d'un environnement réel.

Les principaux objectifs sont :

- administrer un serveur Linux ;
- déployer et maintenir des services conteneurisés ;
- automatiser les tâches d'administration ;
- mettre en place de la supervision ;
- gérer les sauvegardes ;
- sécuriser les accès ;
- documenter l'infrastructure ;
- découvrir les pratiques DevOps et DevSecOps.

## Évolutions prévues

Le projet sera progressivement enrichi avec :

- Prometheus ;
- Grafana ;
- Uptime Kuma ;
- Ansible ;
- GitHub Actions ;
- scripts Bash ;
- sauvegardes automatiques ;
- alertes ;
- durcissement du serveur ;
- Infrastructure as Code.

## Contexte

Ce homelab est un projet personnel réalisé dans le cadre de ma montée en compétences en systèmes Linux, infrastructure, DevOps et cybersécurité.

## Sauvegardes automatiques

Une procédure de sauvegarde automatique de Nextcloud est mise en place avec un script Bash et un timer systemd.

La sauvegarde comprend :

- un dump de la base MariaDB ;
- les fichiers de l'instance Nextcloud ;
- les données utilisateurs ;
- la configuration Docker Compose ;
- une rotation automatique des sauvegardes de plus de 7 jours.

Avant la sauvegarde, Nextcloud est automatiquement placé en mode maintenance afin de garantir la cohérence des données.

Le processus est exécuté automatiquement chaque nuit à 03:00 grâce à systemd.

```text
systemd timer
      |
      v
nextcloud-backup.service
      |
      v
backup-nextcloud.sh
      |
      +--> Maintenance ON
      +--> Dump MariaDB
      +--> Sauvegarde des fichiers
      +--> Maintenance OFF
      +--> Rotation des anciennes sauvegardes
```

Les logs d'exécution peuvent être consultés avec :

```bash
journalctl -u nextcloud-backup.service
```

> Les sauvegardes locales se trouvent actuellement sur le même disque physique que les données Nextcloud. Elles protègent donc principalement contre les suppressions accidentelles ou erreurs de manipulation. Une sauvegarde sur un support distinct ou hors site est prévue pour assurer une véritable reprise après sinistre.

## Automatisation avec Ansible

Une partie de la configuration du homelab est automatisée avec Ansible.

Les playbooks permettent notamment de :

- vérifier et installer les paquets essentiels ;
- s'assurer que Docker est actif ;
- déployer le script de sauvegarde Nextcloud ;
- installer les unités systemd ;
- activer automatiquement le timer de sauvegarde.

```text
Ansible
   |
   +--> Configuration de base
   |      +--> Git
   |      +--> Curl
   |      +--> Rsync
   |      +--> Docker
   |
   +--> Sauvegardes Nextcloud
          +--> Script Bash
          +--> Service systemd
          +--> Timer systemd
```

Les playbooks sont idempotents : une seconde exécution ne modifie pas le système lorsque celui-ci est déjà dans l'état attendu.

## CI/CD avec GitHub Actions

Le homelab dispose d'une chaîne CI/CD permettant de valider automatiquement l'infrastructure avant son déploiement sur le Raspberry Pi.

### Intégration continue

À chaque push sur la branche `main`, GitHub Actions exécute plusieurs contrôles :

- validation de la syntaxe des playbooks Ansible ;
- validation des fichiers Docker Compose ;
- validation de la configuration Prometheus avec `promtool` ;
- validation du `Caddyfile` ;
- analyse du script de sauvegarde avec ShellCheck.

Le déploiement n'est déclenché que si toutes les validations réussissent.

### Déploiement continu

Une fois la CI validée, le repository public déclenche un workflow situé dans un repository privé dédié au déploiement.

Un runner GitHub Actions ARM64 auto-hébergé sur le Raspberry Pi reçoit ensuite le job et déclenche un service systemd dédié.

```text
Développeur
    |
    | git push
    v
GitHub - homelab-devops
    |
    v
GitHub Actions - CI
    |
    +--> Ansible syntax-check
    +--> Docker Compose validation
    +--> Prometheus / promtool
    +--> Caddy validation
    +--> ShellCheck
    |
    | Toutes les validations sont OK
    v
homelab-deploy (repository privé)
    |
    v
GitHub Actions self-hosted runner
    |
    v
Raspberry Pi
    |
    v
homelab-deploy.service
    |
    v
Ansible site.yml
    |
    +--> Configuration Linux
    +--> Sauvegardes Nextcloud
    +--> Monitoring
    +--> Reverse proxy Caddy
```

### Sécurité du déploiement

Le runner de déploiement est associé à un repository privé distinct.

Le compte système utilisé par le runner ne dispose pas d'un accès sudo général. Il est uniquement autorisé à déclencher le service systemd dédié au déploiement.

Le token utilisé par la CI est également limité au repository de déploiement et aux permissions GitHub Actions nécessaires.

Cette séparation permet de conserver le code du homelab public tout en isolant le mécanisme permettant d'exécuter des commandes sur le serveur.
