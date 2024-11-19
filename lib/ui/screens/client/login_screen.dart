import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/auth_controller.dart';

class ClientLoginScreen extends StatelessWidget {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>(); // Obtenez l'instance d'AuthController

    return Scaffold(
      appBar: AppBar(title: Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de Téléphone',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de Passe',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Appelez la méthode login sur l'instance d'AuthController
                authController.login(phoneController.text, passwordController.text);
              },
              child: Text("Se Connecter"),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/client/register'); // Naviguer vers la création de compte
              },
              child: Text("Créer un Compte"),
            ),
          ],
        ),
      ),
    );
  }
}
