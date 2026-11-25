import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/glass_card.dart';

// Écran qui affiche la caméra et renvoie le premier code-barres lu.

class ScannerScreen extends StatefulWidget{
  const ScannerScreen({super.key});

@override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>{
  // Réglages de la caméra pour qu'il se concentre seulement les codes-barres de produits
  final MobileScannerController _controller = MobileScannerController(
    formats: const[
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
    detectionSpeed:  DetectionSpeed.noDuplicates, // évite les détections répétées 
  );

  bool _done = false; // vrai dès qu'un code a été renvoyé

  // Appelée par le package à chaque code détecté.
  void _onDetect(BarcodeCapture capture){
    if(_done) return; // on a déjà un code, on ignore la suite
  
  // "rawValue" est le texte du code-barres (les chiffres
  final code =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null) return;

    _done = true;
    Navigator.pop(context, code);// ferme l'écran et renvoie le code
  }

  @override
  void dispose() {
    _controller.dispose(); // éteint la caméra
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
           // 1) La caméra en plein écran
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // 2) Un cadre au centre pour aider à viser
          Center(
            child: Container(
              width: 280,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 3,
                )
              ),),),

          // 3) Bouton retour en haut à gauche
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2733)),
                  onPressed: () => Navigator.pop(context), // sans renvoyer de code
                ),
              ),
            ),
          ),

          // 4) Texte d'aide en bas, dans une carte en verre
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: const GlassCard(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Text(
                'Place le code-barres dans le cadre',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF1B2733)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}