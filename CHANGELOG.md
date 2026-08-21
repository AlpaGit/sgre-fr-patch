# Changelog

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) et la numérotation
suit [SemVer](https://semver.org/lang/fr/).

## [1.2.0] — 2026-08-21

### Ajouté

- Traduction française de 632 sprites d'interface : menus, paramètres, téléphone,
  historique, glossaire, bibliothèque, aide, sauvegarde et chargement.
- Installation, sauvegarde, vérification SHA-256 et restauration des archives
  `motion_info.psb.m` et `motion_body.bin`.

### Modifié

- Les huit grands logos décoratifs restent dans leur version anglaise originale afin de
  préserver leur typographie et les circuits intégrés au lettrage.
- Documentation et installeur adaptés au patch d'interface.

## [1.1.0] — 2026-08-21

### Ajouté

- Sous-titres français pour les trois vidéos d'introduction du prologue.
- Détection des timings à partir de la visibilité du texte anglais par comparaison d'images
  et OCR.
- Sauvegarde, installation, vérification SHA-256 et restauration automatiques des vidéos.
- Publication des fichiers ASS français dans `sources/video`.

### Modifié

- Documentation d'installation et FAQ adaptées au patch vidéo.
- Archive de release désormais complète : scénario et vidéos sous-titrées.

## [1.0.0] — 2026-08-20

### Ajouté

- Première release publique du patch français pour STEINS;GATE RE:BOOT sur Steam.
- Traduction du prologue scénarisé et des chapitres 1 à 11, routes et True End comprises.
- 23 821 segments modifiés sur 23 875 segments traduisibles recensés.
- Terminologie harmonisée avec les sous-titres français de l'anime de 2011.
- Installeur Windows avec détection des bibliothèques Steam, sauvegarde et vérification SHA-256.
- Désinstalleur restaurant les deux archives originales.

### Limitations

- Les trois vidéos sous-titrées du prologue restent en anglais.
- L'interface et les éléments graphiques comportant du texte ne sont pas encore traduits.
- Première version nécessitant encore une passe de retours en jeu.

### Compatibilité

- STEINS;GATE RE:BOOT Steam, app id 4012810.
- Testé sur le build Steam 24796682 sous Windows.
