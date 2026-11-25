import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/open_food_facts_service.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController(); // lit ce que l'utilisateur tape
  final _service = OpenFoodFactsService();

  bool _loading = false;  // vrai pendant la recherche
  String? _error;         // message d'erreur éventuel
  Product? _product;      // produit trouvé

  // Couleurs de l'application, regroupées pour les changer facilement
  static const _textColor = Color(0xFF1B2733);
  static const _accent = Color(0xFF2F7D6D);

  /// Lance la recherche avec le code-barres saisi.
  Future<void> _search() async {
    final code = _controller.text.trim(); // trim() enlève les espaces
    if (code.isEmpty) return;

    FocusScope.of(context).unfocus(); // ferme le clavier

    // On passe en mode "chargement" et on efface l'ancien résultat
    setState(() {
      _loading = true;
      _error = null;
      _product = null;
    });

    try {
      final result = await _service.fetchProduct(code);
      if (!mounted) return; // l'écran a pu être fermé pendant l'attente
      setState(() {
        _product = result;
        if (result == null) _error = 'Produit introuvable dans la base.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de contacter le serveur. Vérifie ta connexion.';
      });
    } finally {
      // "finally" s'exécute toujours, qu'il y ait eu une erreur ou non
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // libère la mémoire quand l'écran disparaît
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1) Fond : dégradé très doux
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF4F8FB), Color(0xFFE2EEF5)],
              ),
            ),
          ),
          // 2) Deux cercles colorés qui donnent du relief au flou
          Positioned(
            top: -60,
            right: -40,
            child: _blob(220, const Color(0xFFBFE3D6)),
          ),
          Positioned(
            bottom: 80,
            left: -70,
            child: _blob(260, const Color(0xFFC9DDF5)),
          ),
          // 3) Le contenu, dans une zone sûre (hors encoche et barre du haut)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Scanner\nalimentaire',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSearchCard(),
                  const SizedBox(height: 20),
                  _buildResult(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Un cercle coloré flou pour le décor du fond.
  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  /// La carte avec le champ de saisie et le bouton.
  Widget _buildSearchCard() {
    return GlassCard(
      child: Column(
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number, // clavier numérique
            style: const TextStyle(fontSize: 18, color: _textColor),
            decoration: const InputDecoration(
              hintText: 'Code-barres (ex : 3017620422003)',
              border: InputBorder.none, // pas de ligne, plus épuré
            ),
            onSubmitted: (_) => _search(), // touche "valider" du clavier
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, // bouton sur toute la largeur
            child: FilledButton(
              onPressed: _loading ? null : _search, // désactivé pendant la recherche
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Rechercher', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  /// Affiche l'erreur ou le produit, selon ce qu'on a en mémoire.
  Widget _buildResult() {
    if (_error != null) {
      return GlassCard(
        child: Text(
          _error!, // le "!" dit : je suis sûr que ce n'est pas null ici
          style: const TextStyle(fontSize: 16, color: _textColor),
        ),
      );
    }

    final product = _product;
    if (product == null) return const SizedBox.shrink(); // rien à afficher

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.imageUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(product.imageUrl!, height: 160),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.brand,
            style: TextStyle(fontSize: 15, color: _textColor.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ingrédients',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.ingredients,
            style: const TextStyle(fontSize: 15, height: 1.4, color: _textColor),
          ),
        ],
      ),
    );
  }
}