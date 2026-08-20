# STEINS;GATE RE:BOOT — Traduction française

Patch de traduction française non officiel pour **STEINS;GATE RE:BOOT**, version Steam
(*app id 4012810*).

Le scénario anglais du jeu est traduit en français, avec une terminologie harmonisée à
partir des sous-titres français de la série animée de 2011 : **Oopa**, **Oopa en métal**,
**Ruka**, **D-mail**, **ligne d'univers**, **Reading Steiner**, **Champ Attracteur**, etc.

> **Statut — v1.0.0 :** scénario jouable du prologue à la True End, routes comprises.
> Les retours de jeu restent indispensables pour corriger les coquilles et améliorer les
> formulations.

## Pré-requis

- Une copie légitime de **[STEINS;GATE RE:BOOT](https://store.steampowered.com/app/4012810/)** sur Steam.
- Windows 10 ou 11 pour l'installeur automatique.

Le patch est autonome : aucun autre patch ni outil n'est nécessaire pour jouer.

## Installation

1. Téléchargez l'archive `.zip` de la [dernière release](../../releases/latest).
2. Décompressez-la entièrement.
3. Double-cliquez sur **`install.bat`**.
4. Lancez le jeu normalement via Steam.

L'installeur détecte les bibliothèques Steam, sauvegarde les archives anglaises sous les
noms `scenario_info.psb.m.bak` et `scenario_body.bin.bak`, puis copie la VF dans
`wind3d11data`.

Pour une installation manuelle ou Steam Deck, consultez le
[guide détaillé](docs/installation.md).

## Désinstallation

Double-cliquez sur **`uninstall.bat`**. Les deux sauvegardes `.bak` sont restaurées.

Si elles ont été supprimées, utilisez Steam : *Propriétés → Fichiers installés → Vérifier
l'intégrité des fichiers*.

## Contenu traduit

| Contenu | Statut |
|---|---|
| Prologue scénarisé | Traduit |
| Chapitres 1 à 6 | Traduits |
| Chapitre 7 / route Suzuha | Traduit |
| Chapitre 8 / route Faris | Traduit |
| Chapitre 9 / route Ruka | Traduit |
| Chapitre 10 / routes Mayuri et Kurisu | Traduit |
| Chapitre 11 / True End | Traduit |
| Vidéos du prologue avec sous-titres incrustés | Pas encore traduites |
| Interface et éléments graphiques | Pas encore traduits |

Le pipeline recense **23 875 segments traduisibles**, dont **23 821 diffèrent de la source
anglaise (99,8 %)**. Le faible écart correspond principalement aux noms propres, sigles,
onomatopées et formulations identiques dans les deux langues.

## Limitations connues

- Trois vidéos WebM du prologue contiennent des sous-titres anglais incrustés et chiffrés.
  Elles ne font pas partie de cette première release.
- L'interface, certains libellés système et les images comportant du texte restent en anglais.
- La VF a été traduite depuis la localisation anglaise, avec les sous-titres français de
  l'anime comme référence terminologique. Il ne s'agit pas d'une retraduction japonaise.
- Cette première version nécessite encore une passe de test en conditions réelles.

## Signaler un problème

Ouvrez une [issue](../../issues) en indiquant le chapitre, le contexte, la phrase affichée
et, si possible, une capture d'écran. Voir aussi [CONTRIBUTING.md](CONTRIBUTING.md).

## Crédits et mentions légales

Consultez [docs/credits.md](docs/credits.md) et [LICENSE](LICENSE).

Ce projet fan-made est gratuit, non officiel et sans lien avec MAGES. Aucun exécutable,
audio, vidéo ou élément graphique original non modifié n'est distribué. Vous devez posséder
le jeu sur Steam pour utiliser le patch.

*El Psy Congroo.*
