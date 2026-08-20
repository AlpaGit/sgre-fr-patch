# FAQ

### Le jeu reste en anglais après l'installation

Vérifiez que l'installeur a ciblé le bon dossier `SGRE` et que les deux fichiers ont été
remplacés dans `wind3d11data`. Évitez de lancer l'installeur depuis l'intérieur du ZIP.

### Mes sauvegardes de partie sont-elles compatibles ?

Oui. Le patch remplace les archives de scénario, pas les sauvegardes utilisateur. Vous
pouvez revenir à l'anglais avec `uninstall.bat` sans perdre votre progression.

### Pourquoi le texte anglais reste-t-il visible dans les vidéos du prologue ?

L'introduction n'est pas une scène de dialogue ordinaire. Le texte anglais est incrusté
directement dans l'image des trois fichiers `prologue01_en.webm`, `prologue02_en.webm` et
`prologue03_en.webm`. Il ne peut donc pas être désactivé comme une piste de sous-titres.

La v1.1.0 ajoute la traduction française au bas de l'écran sans masquer l'animation. Ses timings
suivent directement l'apparition et la disparition de chaque phrase anglaise, détectées par
comparaison d'images et OCR.

### Pourquoi certains menus restent-ils en anglais ?

La v1.0.0 couvre les archives de scénario. Les textes d'interface et certains éléments
graphiques sont stockés ailleurs et feront l'objet d'un travail séparé.

### La traduction vient-elle du japonais ?

Non. Elle part de la localisation anglaise du jeu. Les sous-titres français de la saison 1
de l'anime ont servi de référence pour les noms, surnoms et termes récurrents.

### Le patch fonctionne-t-il sur Steam Deck ?

La copie manuelle devrait fonctionner sous Proton. L'installeur `.bat` est réservé à
Windows; suivez la section Steam Deck du [guide](installation.md).

### J'ai trouvé une faute ou un contresens

Ouvrez une [issue](../../issues) avec le chapitre, le contexte, la phrase et idéalement
une capture d'écran. Les corrections de terrain sont les bienvenues.
