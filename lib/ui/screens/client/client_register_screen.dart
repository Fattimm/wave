import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../models/transaction_model.dart';
import '../../../models/user_model.dart';

class ClientRegisterScreen extends StatelessWidget {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final photoUrlController = TextEditingController();
  final cniController = TextEditingController();

  final selectedRole = 'client'.obs;

  @override
  Widget build(BuildContext context) {
    // Récupérer une instance d'AuthController
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: Text("Créer un compte Client")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe (6 chiffres)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: photoUrlController,
                decoration: InputDecoration(
                  labelText: 'URL de la photo (facultatif)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: cniController,
                decoration: InputDecoration(
                  labelText: 'CNI',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              // Dropdown pour sélectionner le rôle
              Obx(() => DropdownButtonFormField<String>(
                    value: selectedRole.value,
                    decoration: InputDecoration(
                      labelText: 'Rôle',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        <String>['client', 'distributeur'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) selectedRole.value = newValue;
                    },
                  )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_validateInputs()) {
                    // Créer une transaction initiale avec le nouveau modèle
                    final initialTransaction = TransactionModel.initialDeposit(
                      initiatorPhone: phoneController.text,
                      role: selectedRole.value == 'client'
                          ? UserRole.client
                          : UserRole.distributeur,
                    );

                    // Créer un utilisateur avec la transaction initiale
                    UserModel newUser = UserModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      phone: phoneController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      role: selectedRole.value,
                      cni: cniController.text,
                      photo: photoUrlController.text.isNotEmpty
                          ? photoUrlController.text
                          : null,
                      balance: 0.0,
                      transactions: [initialTransaction],
                    );

                    try {
                      await authController.registerWithEmail(
                        emailController.text,
                        passwordController.text,
                        newUser.toJson(),
                      );
                      Get.snackbar(
                        'Succès',
                        'Compte créé avec succès',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Erreur',
                        'Erreur lors de la création du compte: $e',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  }
                },
                child: Text("Créer un compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction pour valider les entrées
  bool _validateInputs() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        cniController.text.isEmpty) {
      Get.snackbar(
        "Erreur",
        "Tous les champs obligatoires doivent être remplis.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (passwordController.text.length != 6) {
      Get.snackbar(
        "Erreur",
        "Le mot de passe doit contenir 6 chiffres.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }
}
