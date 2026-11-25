import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// Ce service parle à l'API Open Food Facts. Il ne s'occupe pas de l'affichage.
class OpenFoodFactsService {
  /// Cherche un produit avec son code-barres.
  /// Renvoie un Product, ou null si le produit n'existe pas dans la base.
  Future<Product?> fetchProduct(String barcode) async {
    // On construit l'adresse. "fields" limite la réponse aux infos utiles.
    final uri = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json'
      '?fields=product_name,brands,image_url,ingredients_text,nutriscore_grade',
    );

    // On envoie la requête. Le User-Agent dit à l'API qui nous sommes.
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'ScannerAlimentaire/1.0 (app d\'apprentissage)'},
    );

    // 200 = tout va bien. Autre chose = problème réseau ou serveur.
    if (response.statusCode != 200) {
      throw Exception('Erreur réseau : ${response.statusCode}');
    }

    // On transforme le texte JSON reçu en Map utilisable.
    final data = jsonDecode(response.body);

    // status == 1 veut dire que le produit a été trouvé.
    if (data['status'] != 1) return null;

    return Product.fromJson(data['product']);
  }
}