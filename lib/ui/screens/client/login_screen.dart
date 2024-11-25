import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ClientLoginScreen extends StatelessWidget {
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>(); // Obtenez l'instance d'AuthController

    return Scaffold(
      appBar: AppBar(title: Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ pour le numéro de téléphone
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de Téléphone (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              // Champ pour l'email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              // Champ pour le mot de passe
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de Passe',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Bouton de connexion par téléphone
              ElevatedButton(
                onPressed: () async {
                  if (phoneController.text.isNotEmpty) {
                    try {
                      // await authController.sendVerificationCode(phoneController.text);
                      Get.snackbar("Succès", "Un code de vérification a été envoyé par SMS.");
                    } catch (e) {
                      print("Erreur lors de la connexion par téléphone : $e");
                      Get.snackbar("Erreur", "Impossible de se connecter avec le numéro de téléphone.");
                    }
                  } else {
                    Get.snackbar("Erreur", "Veuillez entrer un numéro de téléphone.");
                  }
                },
                child: Text("Se Connecter avec le Numéro de Téléphone"),
              ),
              SizedBox(height: 10),
              // Bouton de connexion par email
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                    try {
                      await authController.loginWithEmail(
                        emailController.text,
                        passwordController.text,
                      );
                    } catch (e) {
                      print("Erreur lors de la connexion par email : $e");
                      Get.snackbar("Erreur", "Impossible de se connecter avec l'email.");
                    }
                  } else {
                    Get.snackbar("Erreur", "Veuillez entrer un email et un mot de passe.");
                  }
                },
                child: Text("Se Connecter avec l'Email"),
              ),
              SizedBox(height: 10),
              // Bouton pour se connecter avec Google
              ElevatedButton(
                onPressed: () async {
                  try {
                    // await authController.loginWithGoogle();
                  } catch (e) {
                    print("Erreur lors de la connexion avec Google : $e");
                    Get.snackbar("Erreur", "Impossible de se connecter avec Google.");
                  }
                },
                child: Text("Se Connecter avec Google"),
              ),
              SizedBox(height: 20),
              // Naviguer vers la page de création de compte
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/client/register'); // Naviguer vers la création de compte
                },
                child: Text("Créer un Compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
