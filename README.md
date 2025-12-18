# 🩺 Visualiseur de Détection de Mélanome

**Application mobile spécialisée pour l'accès aux modèles de détection de cancer de la peau validés.**

---

## 📝 Présentation

Cette application Flutter est un outil éducatif et de démonstration conçu pour simplifier l'accès à plusieurs modèles d'intelligence artificielle hébergés sur **Hugging Face Spaces**. Elle transforme une expérience web complexe en une application mobile fluide et sécurisée.

L'objectif est de permettre aux utilisateurs (étudiants, chercheurs, grand public) de tester différents algorithmes de détection de mélanome via une interface unifiée, sans distractions.

---

## ✨ Fonctionnalités Uniques

### 🔗 Transformation d'URLs Intelligente
Les "Spaces" Hugging Face ont des URLs complexes. L'application intègre un moteur de transformation automatique :
- **Entrée** : `https://huggingface.co/spaces/user/repo`
- **Sortie** : `https://user-repo.hf.space` (URL directe plein écran)

Cette fonctionnalité garantit que l'utilisateur accède toujours à la version la plus pure et fonctionnelle du modèle.

### 🛡️ Mode Kiosque Sécurisé
La navigation est strictement contrôlée. L'utilisateur ne peut naviguer que dans le domaine du modèle actif. Toute tentative de sortir vers des sites externes est bloquée automatiquement, garantissant une utilisation centrée sur l'outil.

### 🎨 Injection CSS "Expérience Native"
Pour offrir une sensation d'application native, du code JavaScript et CSS est injecté à la volée pour :
- Masquer les en-têtes et pieds de page Hugging Face.
- Supprimer les bannières "Show API" ou "Built with Gradio".
- Adapter l'interface pour une utilisation tactile mobile.

### 📷 Gestion des Permissions
L'application gère nativement les demandes d'accès à la **Caméra** et à la **Galerie photo** (Android 13+ supporté), indispensables pour uploader des photos de grains de beauté vers les modèles d'analyse.

---

## 🧠 Modèles Inclus

L'application est pré-configurée avec une sélection de modèles communautaires :

1.  **Melanoma Detector** (par *sapnashettyy*)
2.  **Melanoma Detection System** (par *dehannoor3199*)
3.  **Melanoma Classifier** (par *ish028792*)
4.  **Melanoma Detector v2** (par *sapnashettyy*)
5.  **Melanoma Check** (par *Nachosanchezz*)

*Vous pouvez également ajouter dynamiquement vos propres modèles via l'interface.*

---

## 🛠️ Installation

### Prérequis
- Flutter SDK
- Android Studio (pour l'émulateur ou le build APK)

### Instructions
1.  **Cloner le dépôt** :
    ```bash
    git clone https://github.com/votre-repo/detect_melanoma_1.git
    cd detect_melanoma_1
    ```

2.  **Récupérer les dépendances** :
    ```bash
    flutter pub get
    ```

3.  **Lancer sur Android** :
    ```bash
    flutter run
    ```

---

## ⚠️ Avertissement Médical Important

> **Cette application est un outil de démonstration technologique à but éducatif uniquement.**
>
> Les résultats fournis par les modèles d'IA **ne constituent pas un diagnostic médical**. Ils peuvent comporter des erreurs (faux positifs ou faux négatifs). Ne prenez jamais de décision de santé basée uniquement sur cette application. **En cas de doute sur un grain de beauté ou une lésion cutanée, consultez impérativement un dermatologue ou un médecin qualifié.**
