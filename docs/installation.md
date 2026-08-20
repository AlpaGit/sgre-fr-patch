# Guide d'installation

## Installation automatique sous Windows

1. Téléchargez la dernière archive depuis [GitHub Releases](../../releases/latest).
2. Décompressez tout son contenu. Ne lancez pas le `.bat` directement depuis le ZIP.
3. Double-cliquez sur `install.bat`.
4. L'installeur recherche Steam et ses bibliothèques, puis vérifie le dossier `SGRE`.
5. Une fois l'installation terminée, lancez le jeu via Steam.

Le dossier attendu ressemble à ceci :

```text
…\steamapps\common\SGRE\
└── wind3d11data\
    ├── scenario_info.psb.m
    ├── scenario_body.bin
    └── movie\
        ├── prologue01_en.webm
        ├── prologue02_en.webm
        └── prologue03_en.webm
```

Les archives originales sont conservées avec l'extension `.bak`. Les vidéos originales sont
conservées avec l'extension `.frpatch.bak`.

### Si le jeu n'est pas détecté

Copiez le chemin affiché par Steam via *Gérer → Parcourir les fichiers locaux*, puis
collez-le lorsque l'installeur le demande. Exemple :

```text
G:\SteamLibrary\steamapps\common\SGRE
```

## Installation manuelle

1. Ouvrez `…\steamapps\common\SGRE\wind3d11data\`.
2. Sauvegardez `scenario_info.psb.m` en `scenario_info.psb.m.bak`.
3. Sauvegardez `scenario_body.bin` en `scenario_body.bin.bak`.
4. Sauvegardez les trois fichiers `prologue0*_en.webm` de `wind3d11data\movie\` en leur
   ajoutant l'extension `.frpatch.bak`.
5. Copiez les deux archives du dossier `patch\` dans `wind3d11data\`.
6. Copiez les trois vidéos de `patch\movie\` dans `wind3d11data\movie\`.
7. Acceptez les remplacements, puis lancez le jeu.

Les deux fichiers forment une paire : ne remplacez jamais l'un sans l'autre.

## Steam Deck / Linux

L'installeur PowerShell cible Windows. Sous Proton, effectuez l'installation manuelle dans :

```text
~/.local/share/Steam/steamapps/common/SGRE/wind3d11data/
```

Le chemin peut varier selon la bibliothèque Steam choisie.

## Désinstallation

Sous Windows, lancez `uninstall.bat`. Manuellement, recopiez les deux `.bak` et les trois
`.frpatch.bak` par-dessus les fichiers actifs. Si les sauvegardes manquent, demandez à Steam
de vérifier l'intégrité des fichiers.
