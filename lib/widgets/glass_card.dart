import 'dart:ui';
import 'package:flutter/material.dart';

/// Une carte translucide avec un flou, dans le style "liquid glass" d'iOS.
class GlassCard extends StatelessWidget {
  final Widget child;      // ce qu'on met à l'intérieur de la carte
  final EdgeInsets padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28), // coins bien arrondis
      child: BackdropFilter(
        // Floute l'arrière-plan visible à travers la carte
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // Blanc à 55 % d'opacité : on voit un peu le fond à travers
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(28),
            // Fine bordure claire qui imite le bord du verre
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}