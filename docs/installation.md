# Guide d'installation

## Windows, build Steam 25953359

1. Fermez le jeu. Si vous venez d'une ancienne version du patch, en particulier
   la v1.2.0, ouvrez les propriétés du jeu dans Steam, puis choisissez
   **Fichiers installés > Vérifier l'intégrité des fichiers du jeu**.
2. Téléchargez le ZIP de la [release v1.2.2](../../releases/tag/v1.2.2) et
   décompressez-le entièrement.
3. Double-cliquez sur `install.bat`. L'installeur détecte les bibliothèques Steam.
   S'il vous demande le chemin, récupérez-le dans Steam via **Gérer > Parcourir les
   fichiers locaux**. Exemple : `G:\SteamLibrary\steamapps\common\SGRE`.
4. Lancez le jeu via Steam et choisissez la langue anglaise pour afficher la VF.

L'installeur vérifie le build, les archives d'interface, les fichiers d'origine et
le contenu français. Il conserve les cinq fichiers Steam d'origine dans le dossier
`.sgre-fr-backup-25953359` à la racine de `SGRE`. Il ne lit pas et n'écrase pas les
anciennes sauvegardes `.bak` ou `.frpatch.bak`.

### Si l'installeur refuse de continuer

- **Build incompatible ou jeu en cours de mise à jour :** laissez Steam terminer,
  puis relancez l'installeur. Le patch ne doit pas être forcé sur un autre build.
- **Fichier de jeu modifié :** vérifiez les fichiers dans Steam avant de réessayer.
  Une ancienne version peut avoir laissé des archives d'interface modifiées.
- **Patch incomplet :** téléchargez et extrayez le ZIP nommé
  `sgre-fr-patch-v1.2.2.zip`, pas « Source code (zip) ».

## Désinstallation

Fermez le jeu puis utilisez `uninstall.bat` **du ZIP v1.2.2**. Il vérifie le build
et ses propres sauvegardes avant de restaurer les fichiers d'origine. En cas de
sauvegarde manquante ou si Steam a changé de build, vérifiez l'intégrité des fichiers
dans Steam. Ne restaurez pas les anciens `.bak` par-dessus le jeu.

## Steam Deck et Linux

La v1.2.2 cible le dépôt Windows. L'installeur et les fichiers du jeu sur Steam Deck
ne sont pas validés : n'appliquez pas cette version à un autre dépôt en contournant
les vérifications.
