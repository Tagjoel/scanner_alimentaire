class Product {
  final String name;
  final String brand;
  final String? imageUrl;
  final String ingredients;
  final String? nutriScore;

  Product({
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.ingredients,
    this.nutriScore,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['product_name'] ?? 'Produit sans nom',
      brand: json['brands'] ??  'Marque inconnue',
      imageUrl: json['image_url'],
      ingredients: json['ingredients_text'] ?? 'Ingrédients non renseignés',
      nutriScore: json['nutriscore_grade'],
    );
    }
  }