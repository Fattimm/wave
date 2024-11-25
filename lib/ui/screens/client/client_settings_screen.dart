import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ClientSettingsScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>(); // Récupération de l'AuthController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Écran des paramètres (à personnaliser)",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20), // Espace entre le texte et le bouton
            ElevatedButton(
              onPressed: () async {
                await authController.signOut(); // Appel de la fonction de déconnexion
              },
              child: Text("Déconnexion"),
            ),
          ],
        ),
      ),
    );
  }
}
