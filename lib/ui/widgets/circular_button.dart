import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double radius;
  final double iconSize;
  final double fontSize;

  const CircularButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.radius = 28,
    this.iconSize = 24,
    this.fontSize = 11,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2.5, // Limiter la largeur du container
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onPressed,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(
                icon,
                color: Colors.blue,
                size: iconSize,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Permettre 2 lignes de texte
              overflow: TextOverflow.ellipsis, // Ajouter des points de suspension si nécessaire
            ),
          ),
        ],
      ),
    );
  }
}