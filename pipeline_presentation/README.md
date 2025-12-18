# Pipeline IA - Présentation Interactive

Ce dossier contient une page de présentation interactive du pipeline IA pour le projet "Détecteur de Mélanome".

## 📁 Contenu

- `index.html` : Structure et mise en page principale.
- `style.css` : Styles visuels "Canva", animations et responsive design.
- `script.js` : Logique pour le rendu Markdown, la navigation et les animations.

## 🚀 Comment Lancer

1.  Ouvrez simplement le fichier **`index.html`** dans votre navigateur web préféré (Chrome, Edge, Firefox).
    - Un double-clic sur le fichier suffit généralement.
    - Pas besoin de serveur local (sauf restrictions strictes de navigateur, mais la configuration actuelle est prévue pour fonctionner en local).

## 📝 Comment Ajouter le Contenu

La page utilise des marqueurs d'emplacement (placeholders) pour le contenu. Vous avez deux options :

### Option 1 : Rédaction Directe (Recommandé pour démo rapide)
Copiez-collez votre contenu Markdown dans les fichiers :
- `prompt.md` (si vous en créez un) ou directement dans `index.html` à la place du texte `<!-- PLACEHOLDER... -->`.

### Option 2 : Chargement Dynamique
Sur la page web, cliquez sur l'icône **Upload** (petit dossier/flèche) en haut à droite de chaque carte pour charger vos fichiers `.md` locaux :
1.  **Prompt** : Chargez `docs/02_prompt.md`.
2.  **Tâches** : Chargez `docs/01_taches.md`.
3.  **Plan** : Chargez `docs/03_implementation_plan.md`.
4.  **Walkthrough** : Chargez `docs/04_walkthrough.md`.

Le contenu s'affichera instantanément avec un rendu Markdown propre.

## 🎨 Personnalisation

- **Couleurs** : Modifiez les variables CSS au début de `style.css` (ex: `--primary`, `--secondary`).
- **Polices** : Les polices sont chargées via Google Fonts (Inter, Montserrat) dans `index.html`.

## 📱 Fonctionnalités

- **Navigation Sticky** : Barre de menu fixe pour accès rapide.
- **Circuit Animé** : Un tracé SVG relie les cartes avec une animation fluide.
- **Export PDF** : Cliquez sur le bouton "Exporter PDF" pour une version imprimable propre.
- **Responsive** : S'adapte aux mobiles et tablettes.

---
*Généré par Agent IA pour le projet detect_melanoma_1*
