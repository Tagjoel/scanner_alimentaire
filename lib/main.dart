import 'package:flutter/material.dart';
import  'models/product.dart';
import 'services/open_food_facts_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: TestScreen());
  }
}

class TestScreen extends StatelessWidget{
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test API'),),
      body: Center(
        child: FutureBuilder(
          future: OpenFoodFactsService().fetchProduct('3017620422003'), 
          builder: (context,  snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError){
              return Text('Erreur: ${snapshot.error}');
            }

            final product = snapshot.data;
            if (product == null) return const Text("PRODUIT INTROUVABLE");
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text('${product.name}\n${product.brand}\n\n${product.ingredients}'),);
          }
          )
          ),
    );
  }
}