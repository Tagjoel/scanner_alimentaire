import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

//utilisation de l'api openfoodfactService
class OpenFoodFactsService {
  Future <Product?> fetchProduct(String barcode) async {
    final uri = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json'
      '?fieldsproduct_name,brands,image_url,ingredients_text,nutriscore_grade',
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'ScannerAlimentaire/1.0 (app d\'apprentissage)'},
    );

    if (response.statusCode != 200){
      throw Exception('Erreur réseau : ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    // status == 1 veut dire que le produit a été trouvé
    if (data['status'] != 1) return null;

    return Product.fromJson(data['product']);
  }
}