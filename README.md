# Homelab DevOps

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
- [ ] Sauvegardes automatisées
- [ ] Monitoring avec Prometheus
- [ ] Dashboards Grafana
- [ ] Supervision de disponibilité
- [ ] Automatisation avec Ansible
- [ ] CI/CD avec GitHub Actions
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

