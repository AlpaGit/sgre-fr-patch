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
    └── scenario_body.bin
```

Les originaux sont conservés dans le même dossier avec l'extension `.bak`.

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
4. Copiez les deux fichiers du dossier `patch\` de la release dans `wind3d11data\`.
5. Acceptez le remplacement, puis lancez le jeu.

Les deux fichiers forment une paire : ne remplacez jamais l'un sans l'autre.

## Steam Deck / Linux

L'installeur PowerShell cible Windows. Sous Proton, effectuez l'installation manuelle dans :

```text
~/.local/share/Steam/steamapps/common/SGRE/wind3d11data/
```

Le chemin peut varier selon la bibliothèque Steam choisie.

## Désinstallation

Sous Windows, lancez `uninstall.bat`. Manuellement, recopiez les deux `.bak` par-dessus
les fichiers actifs. Si les sauvegardes manquent, demandez à Steam de vérifier l'intégrité
des fichiers.
