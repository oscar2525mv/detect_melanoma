// content.js - Preloaded content for Melanoma Detector Pipeline Presentation
// This file contains the markdown content embedded as JavaScript strings.

window.preloadedContent = {
    "tasks-content": `# Tâches du Projet : Visualiseur Multi-Modèle de Détection de Mélanome

## Résumé
Créer une nouvelle application Flutter basée sur le projet HF_WebView existant, avec un système multi-modèle pour la détection de mélanome.

---

## Phase 1 : Planification ✅
- [x] Analyser le projet source HF_WebView
- [x] Comprendre la structure et les dépendances
- [x] Créer le plan d'implémentation

## Phase 2 : Création du Nouveau Projet ✅
- [x] Créer le nouveau projet Flutter "detect_melenoma_1"
- [x] Configurer le pubspec.yaml avec les dépendances
- [x] Configurer l'AndroidManifest.xml avec les permissions

## Phase 3 : Implémentation du Code Principal ✅
- [x] Créer la fonction de transformation d'URL Hugging Face
- [x] Créer le modèle de données pour les modèles
- [x] Implémenter le menu de sélection de modèles (Drawer)
- [x] Implémenter l'ajout dynamique de modèles
- [x] Configurer le WebViewController avec blocage de navigation
- [x] Implémenter l'injection CSS/JS pour masquer les éléments HF
- [x] Implémenter la gestion des permissions (Caméra + Galerie)

## Phase 4 : Vérification ✅
- [x] Analyser le code pour erreurs (\`flutter analyze\`)
- [x] Vérifier les dépendances (\`flutter pub get\`)
- [x] Documenter le projet

## Phase 5 : Présentation Interactive (Nouveau)
- [x] Créer le dossier \`pipeline_presentation\`
- [x] Créer \`index.html\` (Structure & Layout)
- [x] Créer \`style.css\` (Design Canva & Animations)
- [x] Créer \`script.js\` (Logique Markdown & Navigation)
- [x] Intégrer les placeholders et la navigation

---

## Statut Final : ✅ TERMINÉ`,

    "prompt-content": `# Prompt Original

## Contexte
Agis en tant qu'expert en Flutter et développement mobile.

## Objectif
Je veux créer un NOUVEAU projet Flutter en me basant sur le code du projet actuel de "Trash/Garbage Detection". La nouvelle application sera un **"Visualiseur Multi-Modèle de Détection de Mélanome"**.

Tu dois prendre en charge la création complète du fichier en incluant toutes les logiques de configuration, permissions et injection de scripts.

---

## Règle Critique : Transformation des URLs

Les "Hugging Face Spaces" ont une URL publique et une URL directe. Tu dois implémenter une fonction qui transforme automatiquement toute URL fournie par moi ou par l'utilisateur selon cette logique :

- **Entrée (Originale) :** \`https://huggingface.co/spaces/UTILISATEUR/REPO\`
- **Sortie (Directe) :** \`https://UTILISATEUR-REPO.hf.space\`
- **Logique :** Remplace le slash \`/\` entre l'utilisateur et le nom du repo par un tiret \`-\`, et change le domaine en \`.hf.space\`.

---

## Fonctionnalités Requises

### 1. Menu de Sélection de Modèles
Implémente une interface ergonomique pour basculer rapidement entre différents modèles.

### 2. Liste Initiale de Modèles
L'application doit démarrer avec cette liste préchargée. Applique la règle de transformation ci-dessus à ces URL originales avant de les charger :

- \`https://huggingface.co/spaces/sapnashettyy/melanoma-detector\`
- \`https://huggingface.co/spaces/ish028792/melanoma\`
- \`https://huggingface.co/spaces/dehannoor3199/melanoma-detection-system\`
- \`https://huggingface.co/spaces/sapnashettyy/melanoma-detector2\`
- \`https://huggingface.co/spaces/Nachosanchezz/Melanoma\`

### 3. Ajout Dynamique de Modèle
Ajoute un moyen pour l'utilisateur d'ajouter une nouvelle URL originale Hugging Face. Le code doit détecter le format et le transformer automatiquement.

### 4. Blocage de Navigation
Modifie le \`NavigationDelegate\` pour autoriser uniquement la navigation au sein du domaine \`.hf.space\` du modèle actif et bloquer tout le reste pour que l'utilisateur ne sorte pas de l'outil.

### 5. Amélioration Visuelle
Le but est que l'application ressemble le plus possible à une application native.
- Implémente une logique d'injection JavaScript/CSS.
- **Mission :** Propose et intègre un code CSS intelligent pour masquer les éléments de l'interface web de Hugging Face qui ne sont pas nécessaires dans une app mobile (comme les headers, footers, ou barres de navigation web), afin d'offrir une expérience utilisateur propre et immersive.

### 6. Gestion des Permissions
Le code doit inclure toute la logique nécessaire pour demander l'accès à la **Caméra** et à la **Galerie**, car ces modèles nécessitent l'upload d'images. Réplique la logique robuste du projet base pour la compatibilité Android.

---

## Livrable
Génère le code complet et fonctionnel dans un projet nouveau.`,

    "plan-content": `# Plan d'Implémentation : Visualiseur Multi-Modèle de Détection de Mélanome

Application Flutter permettant de basculer entre différents modèles de détection de mélanome hébergés sur Hugging Face Spaces.

## Aperçu

L'application transformera automatiquement les URLs Hugging Face en URLs directes \`.hf.space\`, permettra à l'utilisateur de sélectionner parmi plusieurs modèles pré-configurés, d'en ajouter dynamiquement, et offrira une expérience native en masquant les éléments d'interface Hugging Face.

---

## Règle de Transformation d'URL

\`\`\`
Entrée  : https://huggingface.co/spaces/UTILISATEUR/REPO
Sortie  : https://UTILISATEUR-REPO.hf.space
\`\`\`

**Exemple :**
- \`https://huggingface.co/spaces/sapnashettyy/melanoma-detector\`
- → \`https://sapnashettyy-melanoma-detector.hf.space\`

---

## Modèles Initiaux

| Nom du Modèle | URL Originale | URL Transformée |
|---------------|---------------|-----------------|
| Melanoma Detector (sapnashettyy) | \`https://huggingface.co/spaces/sapnashettyy/melanoma-detector\` | \`https://sapnashettyy-melanoma-detector.hf.space\` |
| Melanoma (ish028792) | \`https://huggingface.co/spaces/ish028792/melanoma\` | \`https://ish028792-melanoma.hf.space\` |
| Melanoma Detection System | \`https://huggingface.co/spaces/dehannoor3199/melanoma-detection-system\` | \`https://dehannoor3199-melanoma-detection-system.hf.space\` |
| Melanoma Detector 2 | \`https://huggingface.co/spaces/sapnashettyy/melanoma-detector2\` | \`https://sapnashettyy-melanoma-detector2.hf.space\` |
| Melanoma (Nachosanchezz) | \`https://huggingface.co/spaces/Nachosanchezz/Melanoma\` | \`https://Nachosanchezz-Melanoma.hf.space\` |

---

## Structure du Projet

\`\`\`
detect_melenoma_1/
├── lib/
│   └── main.dart                 # Code principal de l'application
├── android/
│   └── app/
│       └── src/
│           └── main/
│               ├── AndroidManifest.xml    # Permissions Android
│               └── res/
│                   └── xml/
│                       └── file_paths.xml # FileProvider config
├── pubspec.yaml                  # Dépendances Flutter
└── docs/                         # Documentation
\`\`\`

---

## Fichiers à Créer

### 1. pubspec.yaml

Configuration du projet avec les dépendances :
- \`webview_flutter\` et \`webview_flutter_android\` pour le WebView
- \`permission_handler\` pour les permissions caméra/galerie
- \`image_picker\` pour la sélection d'images
- \`shared_preferences\` pour la persistance des modèles ajoutés

### 2. lib/main.dart

Fichier principal contenant :

1. **Classe \`MelanomaModel\`** - Modèle de données avec :
   - \`name\` : Nom affiché
   - \`originalUrl\` : URL Hugging Face originale
   - \`directUrl\` : URL transformée (calculée automatiquement)

2. **Fonction \`transformHuggingFaceUrl()\`** - Transformation automatique :
   \`\`\`dart
   // Entrée : https://huggingface.co/spaces/USER/REPO
   // Sortie : https://USER-REPO.hf.space
   \`\`\`

3. **Interface de sélection de modèles** - Drawer latéral ergonomique avec :
   - Liste des modèles disponibles
   - Indicateur du modèle actif
   - Bouton d'ajout de nouveau modèle

4. **Boîte de dialogue d'ajout dynamique** - Permet à l'utilisateur d'entrer une URL originale

5. **NavigationDelegate restrictif** - Bloque toute navigation hors du domaine \`.hf.space\` actif

6. **Injection CSS/JS avancée** - Masque :
   - Headers et footers Hugging Face
   - Boutons "Show API"
   - Bannières de chargement
   - Navigation Gradio

### 3. AndroidManifest.xml

Permissions Android requises :
- \`INTERNET\`
- \`CAMERA\`
- \`READ_EXTERNAL_STORAGE\` (Android < 13)
- \`READ_MEDIA_IMAGES\` (Android 13+)

### 4. file_paths.xml

Configuration FileProvider pour compatibilité image_picker.

---

## Plan de Vérification

### Tests Automatisés
- Analyse statique avec \`flutter analyze\`
- Compilation avec \`flutter build apk --debug\`

### Vérification Manuelle
- Test de la fonction de transformation d'URL
- Test du changement de modèle
- Test de l'ajout dynamique de modèle
- Test du blocage de navigation`,

    "walkthrough-content": `# Walkthrough : Visualiseur Multi-Modèle de Détection de Mélanome

## ✅ Résumé du Travail Accompli

Application Flutter complète permettant de visualiser et basculer entre plusieurs modèles de détection de mélanome hébergés sur Hugging Face Spaces.

---

## 📁 Fichiers Créés

| Fichier | Description |
|---------|-------------|
| \`pubspec.yaml\` | Configuration avec dépendances WebView, permissions, image_picker |
| \`lib/main.dart\` | Code principal avec toute la logique de l'application |
| \`android/app/src/main/AndroidManifest.xml\` | Permissions Android (Caméra, Galerie, Internet) |
| \`android/app/build.gradle.kts\` | Configuration Gradle avec résolution de conflit activity |
| \`android/app/src/main/res/xml/file_paths.xml\` | Configuration FileProvider pour image_picker |

---

## 🔧 Fonctionnalités Implémentées

### 1. Transformation d'URL Hugging Face

\`\`\`dart
/// Transforme une URL Hugging Face originale en URL directe .hf.space
/// Entrée : https://huggingface.co/spaces/UTILISATEUR/REPO
/// Sortie : https://UTILISATEUR-REPO.hf.space
static String transformHuggingFaceUrl(String originalUrl) {
  // Si c'est déjà une URL directe, la retourner telle quelle
  if (originalUrl.contains('.hf.space')) {
    return originalUrl;
  }

  // Pattern: https://huggingface.co/spaces/USER/REPO
  final regex = RegExp(r'https?://huggingface\\.co/spaces/([^/]+)/([^/\\s]+)');
  final match = regex.firstMatch(originalUrl);

  if (match != null) {
    final user = match.group(1)!;
    final repo = match.group(2)!;
    return 'https://$user-$repo.hf.space';
  }

  // Si le format n'est pas reconnu, retourner l'URL originale
  return originalUrl;
}
\`\`\`

### 2. Liste des Modèles Pré-chargés

| Modèle | URL Transformée |
|--------|-----------------|
| Melanoma Detector (sapnashettyy) | \`sapnashettyy-melanoma-detector.hf.space\` |
| Melanoma (ish028792) | \`ish028792-melanoma.hf.space\` |
| Melanoma Detection System | \`dehannoor3199-melanoma-detection-system.hf.space\` |
| Melanoma Detector 2 | \`sapnashettyy-melanoma-detector2.hf.space\` |
| Melanoma (Nachosanchezz) | \`Nachosanchezz-Melanoma.hf.space\` |

### 3. Menu de Sélection de Modèles

- Drawer latéral avec liste des modèles
- Indicateur du modèle actif (icône check)
- Bouton d'ajout dynamique de modèle
- Design Material 3 avec thème sombre violet

### 4. Ajout Dynamique de Modèles

- Dialogue pour entrer une URL Hugging Face originale
- Transformation automatique en URL directe
- Persistance automatique via SharedPreferences
- Validation du format d'URL

### 5. Blocage de Navigation (Mode Kiosque)

\`\`\`dart
onNavigationRequest: (NavigationRequest request) {
  final currentDomain = _extractDomain(_currentModel.directUrl);
  if (request.url.contains(currentDomain) || 
      request.url.startsWith(_currentModel.directUrl)) {
    return NavigationDecision.navigate;
  }
  debugPrint('Navigation bloquée vers: \${request.url}');
  return NavigationDecision.prevent;
}
\`\`\`

### 6. Injection CSS/JS pour Apparence Native

Le code injecte un CSS qui masque automatiquement :
- ✅ Headers et footers Hugging Face
- ✅ Boutons "Show API" et "Built with Gradio"
- ✅ Liens de branding Gradio
- ✅ Éléments de navigation Gradio
- ✅ Amélioration du style de scrollbar

### 7. Gestion des Permissions Android

\`\`\`dart
Future<void> _requestPermissions() async {
  await Permission.camera.request();
  if (Platform.isAndroid) {
    // Android 13+ utilise READ_MEDIA_IMAGES
    if (await Permission.photos.status.isDenied) {
      await Permission.photos.request();
    }
    // Android < 13 utilise READ_EXTERNAL_STORAGE
    if (await Permission.storage.status.isDenied) {
      await Permission.storage.request();
    }
  }
}
\`\`\`

---

## 🧪 Vérification

### Analyse Statique
\`\`\`bash
$ flutter analyze
Analyzing detect_melenoma_1...
No issues found! (ran in 2.5s)
\`\`\`

### Dépendances
\`\`\`bash
$ flutter pub get
Resolving dependencies...
Got dependencies!
\`\`\`

---

## 🚀 Comment Lancer l'Application

\`\`\`bash
# Se placer dans le répertoire du projet
cd detect_melenoma_1

# Télécharger les dépendances
flutter pub get

# Lancer sur Android (émulateur ou appareil connecté)
flutter run

# Ou construire l'APK
flutter build apk
\`\`\`

---

## 📱 Interface Utilisateur

L'application utilise **Material Design 3** avec un thème sombre violet. Elle comprend :

1. **AppBar** - Affiche le nom du modèle actif + boutons Refresh/Aide
2. **Drawer** - Menu latéral pour sélection et ajout de modèles
3. **WebView** - Affichage plein écran du modèle Hugging Face
4. **FAB** - Boutons flottants pour navigation avant/arrière
5. **Overlay de chargement** - Animation pendant le chargement des pages
6. **Dialogue d'aide** - Instructions d'utilisation

---

## ⚠️ Avertissement

> Cette application est à but **éducatif uniquement**. Les résultats de détection de mélanome fournis par les modèles ne remplacent **pas** un avis médical professionnel. Consultez toujours un dermatologue pour tout diagnostic.

---

## 📂 Emplacement du Projet

\`\`\`
c:\\Users\\martv\\Proyect\\projet_webview\\HF_WebView\\detect_melenoma_1\\
\`\`\``
};
