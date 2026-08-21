# STEINS;GATE RE:BOOT — Traduction française

Patch de traduction française non officiel pour **STEINS;GATE RE:BOOT**, version Steam
(*app id 4012810*).

Le scénario anglais du jeu est traduit en français, avec une terminologie harmonisée à
partir des sous-titres français de la série animée de 2011 : **Oopa**, **Oopa en métal**,
**Ruka**, **D-mail**, **ligne d'univers**, **Reading Steiner**, **Champ Attracteur**, etc.

> **Statut — v1.2.0 :** scénario jouable du prologue à la True End, routes comprises,
> sous-titres français sur les trois vidéos d'introduction et interface traduite.
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

L'installeur détecte les bibliothèques Steam, sauvegarde les archives anglaises du scénario
et de l'interface ainsi que les trois vidéos originales, puis copie la VF dans `wind3d11data`.

Pour une installation manuelle ou Steam Deck, consultez le
[guide détaillé](docs/installation.md).

## Désinstallation

Double-cliquez sur **`uninstall.bat`**. Les quatre sauvegardes `.bak` et les vidéos originales
sont restaurées.

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
| Vidéos du prologue avec texte incrusté | Sous-titrées en français |
| Interface et éléments graphiques | Traduits |

Le pipeline recense **23 875 segments traduisibles**, dont **23 821 diffèrent de la source
anglaise (99,8 %)**. Le faible écart correspond principalement aux noms propres, sigles,
onomatopées et formulations identiques dans les deux langues.

## Limitations connues

- Le texte anglais d'origine reste visible au centre des vidéos d'introduction, car il est
  incrusté dans l'image. La v1.1.0 ajoute la traduction française au bas de l'écran, avec les
  mêmes temps d'apparition et de disparition.
- Les grands logos décoratifs (`CONFIG`, `BACKLOG`, `TIPS LIST`, `LIBRARY`, `OBSERVER`,
  `SAVE`, `LOAD` et `QUICK LOAD`) restent volontairement en anglais : leur lettrage est
  directement imbriqué dans les circuits du dessin original.
- La VF a été traduite depuis la localisation anglaise, avec les sous-titres français de
  l'anime comme référence terminologique. Il ne s'agit pas d'une retraduction japonaise.
- Cette première version nécessite encore une passe de test en conditions réelles.

Les vidéos ont été déchiffrées, sous-titrées, réencodées en VP9 puis rechiffrées pour le moteur.
Les timings suivent directement l'apparition du texte anglais, détectée par comparaison d'images
et OCR. Les fichiers ASS utilisés sont publiés dans [`sources/video`](sources/video).

## Signaler un problème

Ouvrez une [issue](../../issues) en indiquant le chapitre, le contexte, la phrase affichée
et, si possible, une capture d'écran. Voir aussi [CONTRIBUTING.md](CONTRIBUTING.md).

## Crédits et mentions légales

Consultez [docs/credits.md](docs/credits.md) et [LICENSE](LICENSE).

Ce projet fan-made est gratuit, non officiel et sans lien avec MAGES. Aucun exécutable,
audio, vidéo ou élément graphique original non modifié n'est distribué. Vous devez posséder
le jeu sur Steam pour utiliser le patch.

*El Psy Congroo.*
