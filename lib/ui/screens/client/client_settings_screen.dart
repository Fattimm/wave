import 'package:flutter/material.dart';

class ClientSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres"),
      ),
      body: Center(
        child: Text(
          "Écran des paramètres (à personnaliser)",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
