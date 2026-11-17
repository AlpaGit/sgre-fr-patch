# Reconstruire le patch du build 25953359

Ces outils sont destinés à la maintenance. Le ZIP de la release ne nécessite ni Python
ni FreeMote.

## Préparer les trois sources

1. Utilisez Python 3.11 ou plus récent et [FreeMote 4.9.0](https://github.com/UlyssesWu/FreeMote/releases/tag/v4.9.0).
2. Dans un nouveau dossier de travail, placez FreeMote dans `tools/` et créez trois
   dossiers au même niveau : `old/` pour les archives de scénario originales de la
   version d'août (dépôt Steam Windows 4012811, manifeste 4900984998756496132),
   `current/` pour le build 25953359 (même dépôt, manifeste 4014866143715744466) et
   `fr/` pour les archives françaises de la v1.2.1. Chaque dossier doit contenir
   `scenario_info.psb.m` et `scenario_body.bin`. Les originaux Steam ne sont
   pas fournis. Vérifiez les empreintes des fichiers actuels et français contre celles
   d'`installer/build.json` et de la v1.2.1 respectivement.
3. Dans chacun de ces trois dossiers, exécutez ces commandes PowerShell pour extraire
   l'index et décompiler les scènes. L'outil d'extraction doit annoncer zéro échec.

```powershell
..\tools\PsbDecompile.exe info-psb -k Rk3nwA8ZYV0yV --infer-key-length scenario_info.psb.m
Push-Location scenario
try {
    $scenes = (Get-ChildItem -Filter '*.scn.m').Name
    ..\..\tools\PsbDecompile.exe -raw -indent @scenes
} finally { Pop-Location }
```

## Recompiler, vérifier et empaqueter

Depuis le dépôt, avec le chemin du dossier de travail de l'étape précédente :

```powershell
python tools/rebase.py C:\chemin\travail make
python tools/rebase.py C:\chemin\travail verify
```

`make` conserve les scènes françaises dont l'équivalent Steam est inchangé et
reporte le texte FR sur les scènes mises à jour, avec les corrections définies dans
`rebase.py`. Une ligne sans correspondance interrompt la construction. `verify`
réextrait les 189 entrées, compare l'index, vérifie les scènes recopiées octet par
octet et compare la structure des scènes recompilées. Une petite tolérance couvre
le réarrondi des flottants par FreeMote. Cela ne remplace pas une validation en jeu.

Les archives vérifiées se trouvent dans `verified-final/`. Pour une nouvelle
version, copiez-les dans `patch/` et synchronisez les empreintes dans
`installer/build.json`, `SHA256SUMS.txt` et `patch/README.md`.
Pour empaqueter la v1.2.2 avec les vidéos de la v1.2.1 :

```powershell
python tools/pack.py --movies C:\chemin\v1.2.1\patch\movie dist/sgre-fr-patch-v1.2.2.zip
```

Vérifiez que l'installeur tourne sur Windows PowerShell 5.1, puis lancez
`python -m unittest discover -s tests -v` pour ses tests d'intégration.
