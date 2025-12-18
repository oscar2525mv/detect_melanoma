import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MelanomaDetectorApp());
}

// =============================================================================
// MODÈLE DE DONNÉES
// =============================================================================

class MelanomaModel {
  final String name;
  final String originalUrl;
  late final String directUrl;

  MelanomaModel({required this.name, required this.originalUrl}) {
    directUrl = transformHuggingFaceUrl(originalUrl);
  }

  /// Transforme une URL Hugging Face originale en URL directe .hf.space
  /// Entrée : https://huggingface.co/spaces/UTILISATEUR/REPO
  /// Sortie : https://UTILISATEUR-REPO.hf.space
  static String transformHuggingFaceUrl(String originalUrl) {
    // Si c'est déjà une URL directe, la retourner telle quelle
    if (originalUrl.contains('.hf.space')) {
      return originalUrl;
    }

    // Pattern: https://huggingface.co/spaces/USER/REPO
    final regex = RegExp(r'https?://huggingface\.co/spaces/([^/]+)/([^/\s]+)');
    final match = regex.firstMatch(originalUrl);

    if (match != null) {
      final user = match.group(1)!;
      final repo = match.group(2)!;
      // Convertir en minuscules et remplacer les underscores par des tirets
      final safeUser = user.toLowerCase().replaceAll('_', '-');
      final safeRepo = repo.toLowerCase().replaceAll('_', '-');
      return 'https://$safeUser-$safeRepo.hf.space';
    }

    // Si le format n'est pas reconnu, retourner l'URL originale
    return originalUrl;
  }

  Map<String, dynamic> toJson() => {'name': name, 'originalUrl': originalUrl};

  factory MelanomaModel.fromJson(Map<String, dynamic> json) {
    return MelanomaModel(
      name: json['name'] as String,
      originalUrl: json['originalUrl'] as String,
    );
  }
}

// =============================================================================
// APPLICATION PRINCIPALE
// =============================================================================

class MelanomaDetectorApp extends StatelessWidget {
  const MelanomaDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Détecteur de Mélanome',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const MelanomaDetectorPage(),
    );
  }
}

// =============================================================================
// PAGE PRINCIPALE
// =============================================================================

class MelanomaDetectorPage extends StatefulWidget {
  const MelanomaDetectorPage({super.key});

  @override
  State<MelanomaDetectorPage> createState() => _MelanomaDetectorPageState();
}

class _MelanomaDetectorPageState extends State<MelanomaDetectorPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  int _currentModelIndex = 0;

  // Liste des modèles pré-chargés
  List<MelanomaModel> _models = [
    MelanomaModel(
      name: 'Melanoma Detector (sapnashettyy)',
      originalUrl:
          'https://huggingface.co/spaces/sapnashettyy/melanoma-detector',
    ),
    MelanomaModel(
      name: 'Melanoma (ish028792)',
      originalUrl: 'https://huggingface.co/spaces/ish028792/melanoma',
    ),
    MelanomaModel(
      name: 'Melanoma Detection System',
      originalUrl:
          'https://huggingface.co/spaces/dehannoor3199/melanoma-detection-system',
    ),
    MelanomaModel(
      name: 'Melanoma Detector 2',
      originalUrl:
          'https://huggingface.co/spaces/sapnashettyy/melanoma-detector2',
    ),
    MelanomaModel(
      name: 'Melanoma (Nachosanchezz)',
      originalUrl: 'https://huggingface.co/spaces/Nachosanchezz/Melanoma',
    ),
  ];

  MelanomaModel get _currentModel => _models[_currentModelIndex];

  @override
  void initState() {
    super.initState();
    _loadSavedModels();
    _requestPermissions();
    _initializeWebView();
  }

  // ---------------------------------------------------------------------------
  // PERSISTANCE DES MODÈLES
  // ---------------------------------------------------------------------------

  Future<void> _loadSavedModels() async {
    final prefs = await SharedPreferences.getInstance();
    final savedModels = prefs.getString('custom_models');
    if (savedModels != null) {
      final List<dynamic> decoded = jsonDecode(savedModels);
      final customModels =
          decoded.map((e) => MelanomaModel.fromJson(e)).toList();
      setState(() {
        _models = [..._models, ...customModels];
      });
    }
  }

  Future<void> _saveCustomModels() async {
    final prefs = await SharedPreferences.getInstance();
    // Sauvegarder uniquement les modèles ajoutés (après les 5 premiers)
    final customModels = _models.skip(5).map((m) => m.toJson()).toList();
    await prefs.setString('custom_models', jsonEncode(customModels));
  }

  // ---------------------------------------------------------------------------
  // INITIALISATION DU WEBVIEW
  // ---------------------------------------------------------------------------

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1C1B1F))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _injectCustomStyles();
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur de chargement: ${error.description}'),
                backgroundColor: Colors.red.shade700,
              ),
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            // Bloquer la navigation en dehors du domaine .hf.space actuel
            final currentDomain = _extractDomain(_currentModel.directUrl);
            if (request.url.contains(currentDomain) ||
                request.url.startsWith(_currentModel.directUrl)) {
              return NavigationDecision.navigate;
            }
            debugPrint('Navigation bloquée vers: ${request.url}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Navigation externe bloquée'),
                backgroundColor: Colors.orange.shade700,
                duration: const Duration(seconds: 2),
              ),
            );
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentModel.directUrl));

    // Configuration spécifique Android
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);

      // Sélecteur de fichiers pour Android (Caméra/Galerie)
      (controller.platform as AndroidWebViewController).setOnShowFileSelector((
        FileSelectorParams params,
      ) async {
        final source = await _showImageSourceDialog();
        if (source == null) return [];

        final picker = ImagePicker();
        final photo = await picker.pickImage(source: source);
        if (photo == null) return [];

        return [Uri.file(photo.path).toString()];
      });
    }

    _controller = controller;
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return '';
    }
  }

  // ---------------------------------------------------------------------------
  // INJECTION CSS/JS POUR APPARENCE NATIVE
  // ---------------------------------------------------------------------------

  Future<void> _injectCustomStyles() async {
    const String cssInjection = """
      (function() {
        var style = document.createElement('style');
        style.id = 'melanoma-app-custom-styles';
        style.innerHTML = `
          /* Masquer les headers et footers Hugging Face */
          footer, .footer, 
          header, .header,
          .show-api, .show-api-btn,
          .built-with, .built-with-gradio,
          .svelte-1ed2p3z, /* Gradio footer class */
          [class*="footer"],
          .gr-footer,
          nav.svelte-1kcgrqr,
          .contain > .gap-4 > div:last-child,
          .gradio-container > footer,
          .gradio-container > .footer,
          div[class*="footer"] {
            display: none !important;
            visibility: hidden !important;
            height: 0 !important;
            overflow: hidden !important;
          }
          
          /* Masquer les éléments de branding Gradio */
          .gradio-container .gr-prose a[href*="gradio.app"],
          .gradio-container .gr-prose a[href*="huggingface"],
          a[href*="gradio.app"],
          a[href*="huggingface.co"]:not([href*="spaces"]) {
            display: none !important;
          }
          
          /* Masquer les bannières de chargement HF */
          .progress-bar-wrap,
          .generating,
          #loading {
            z-index: 1 !important;
          }
          
          /* Ajuster le padding/margin */
          body {
            padding-top: 0px !important;
            margin-top: 0px !important;
          }
          
          .gradio-container {
            margin-top: 0 !important;
            padding-top: 8px !important;
          }
          
          /* Style scroll plus natif */
          ::-webkit-scrollbar {
            width: 4px;
          }
          
          ::-webkit-scrollbar-track {
            background: transparent;
          }
          
          ::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.3);
            border-radius: 4px;
          }
          
          /* Améliorer la zone de drop pour images */
          .upload-container, .image-container,
          [data-testid="image"], .gr-image {
            min-height: 200px;
          }
        `;
        
        // Supprimer l'ancien style s'il existe
        var oldStyle = document.getElementById('melanoma-app-custom-styles');
        if (oldStyle) oldStyle.remove();
        
        document.head.appendChild(style);
        
        // Observer pour les éléments ajoutés dynamiquement
        var observer = new MutationObserver(function(mutations) {
          var footer = document.querySelector('footer, .footer');
          if (footer) footer.style.display = 'none';
        });
        
        observer.observe(document.body, { childList: true, subtree: true });
      })();
    """;

    try {
      await _controller.runJavaScript(cssInjection);
    } catch (e) {
      debugPrint("Erreur d'injection CSS: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // PERMISSIONS
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // DIALOGUES
  // ---------------------------------------------------------------------------

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Source de l\'image'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
                title: const Text('Appareil photo'),
                subtitle: const Text('Prendre une nouvelle photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.photo_library)),
                title: const Text('Galerie'),
                subtitle: const Text('Choisir une image existante'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddModelDialog() async {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un modèle'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du modèle',
                  hintText: 'Ex: Mon Détecteur',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL Hugging Face',
                  hintText: 'https://huggingface.co/spaces/user/repo',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 8),
              Text(
                'L\'URL sera automatiquement transformée en format direct.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    if (result == true && urlController.text.isNotEmpty) {
      String modelName = nameController.text.trim();

      // Logique d'auto-nommage si le nom est vide
      if (modelName.isEmpty) {
        final regex = RegExp(
          r'https?://huggingface\.co/spaces/([^/]+)/([^/\s]+)',
        );
        final match = regex.firstMatch(urlController.text);
        if (match != null) {
          modelName = match.group(2)!; // Utiliser le nom du repo
        } else {
          modelName = 'Modèle personnalisé ${_models.length + 1}';
        }
      }

      final newModel = MelanomaModel(
        name: modelName,
        originalUrl: urlController.text,
      );

      setState(() {
        _models.add(newModel);
      });
      await _saveCustomModels();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modèle "${newModel.name}" ajouté'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Réinitialiser ?'),
            content: const Text(
              'Voulez-vous vraiment supprimer tous les modèles personnalisés ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_models');
      setState(() {
        if (_models.length > 5) {
          _models.removeRange(5, _models.length);
        }
        _currentModelIndex = 0;
        _isLoading = true;
      });
      _controller.loadRequest(Uri.parse(_currentModel.directUrl));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Modèles réinitialisés par défaut'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      // Fermer le drawer si ouvert (techniquement on est resté sur la page mais le drawer est au dessus)
      if (Scaffold.of(context).isDrawerOpen) {
        Navigator.pop(context);
      }
    }
  }

  void _switchModel(int index) {
    if (index != _currentModelIndex) {
      setState(() {
        _currentModelIndex = index;
        _isLoading = true;
      });
      _controller.loadRequest(Uri.parse(_currentModel.directUrl));
      Navigator.pop(context); // Fermer le drawer
    }
  }

  // ---------------------------------------------------------------------------
  // INTERFACE UTILISATEUR
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentModel.name,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Sélectionner un modèle',
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Aide',
          ),
        ],
      ),
      drawer: _buildModelDrawer(),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: _buildNavigationFAB(),
    );
  }

  Widget _buildModelDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Détecteur de Mélanome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_models.length} modèles disponibles',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _models.length,
              itemBuilder: (context, index) {
                final model = _models[index];
                final isSelected = index == _currentModelIndex;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade700,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    model.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    model.directUrl,
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : null,
                  selected: isSelected,
                  onTap: () => _switchModel(index),
                  onLongPress: () => _showModelDetailsDialog(model),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.add)),
            title: const Text('Ajouter un modèle'),
            subtitle: const Text('URL Hugging Face'),
            onTap: () {
              Navigator.pop(context);
              _showAddModelDialog();
            },
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.restore, color: Colors.white),
            ),
            title: const Text(
              'Réinitialiser',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.pop(context);
              _resetToDefaults();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showModelDetailsDialog(MelanomaModel model) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(model.name),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailItem(
                    'URL Originale',
                    model.originalUrl,
                    Icons.link,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    'URL Directe (Transformée)',
                    model.directUrl,
                    Icons.transform,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color ?? Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: TextStyle(
            color: color ?? Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Chargement de ${_currentModel.name}...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _currentModel.directUrl,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationFAB() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'back',
          mini: true,
          tooltip: 'Retour',
          onPressed: () async {
            if (await _controller.canGoBack()) {
              _controller.goBack();
            }
          },
          child: const Icon(Icons.arrow_back),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'forward',
          mini: true,
          tooltip: 'Suivant',
          onPressed: () async {
            if (await _controller.canGoForward()) {
              _controller.goForward();
            }
          },
          child: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.help_outline),
                SizedBox(width: 8),
                Text('Comment utiliser'),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📱 Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text('1. Attendez le chargement du modèle'),
                  SizedBox(height: 6),
                  Text('2. Cliquez sur la zone d\'upload'),
                  SizedBox(height: 6),
                  Text('3. Prenez une photo ou sélectionnez depuis la galerie'),
                  SizedBox(height: 6),
                  Text('4. Attendez l\'analyse'),
                  SizedBox(height: 6),
                  Text('5. Consultez le résultat de détection'),
                  SizedBox(height: 16),
                  Text(
                    '🔄 Changer de modèle:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ouvrez le menu latéral (☰) pour sélectionner un autre modèle de détection.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    '⚠️ Avertissement:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cette application est à but éducatif uniquement. Consultez toujours un professionnel de santé pour tout diagnostic médical.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Compris !'),
              ),
            ],
          ),
    );
  }
}
