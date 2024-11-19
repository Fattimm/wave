import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/client_controller.dart';

class ClientRegisterScreen extends StatelessWidget {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final photoUrlController = TextEditingController();
  final cniController = TextEditingController();

  // Utilisation de GetX pour rendre selectedRole observable
  final selectedRole = 'client'.obs;

  @override
  Widget build(BuildContext context) {
    final clientController = Get.find<ClientController>();

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
                  labelText: 'Mot de passe (4 chiffres)',
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
                    items: <String>['client', 'distributeur'].map((String value) {
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
                onPressed: () {
                  if (_validateInputs(context)) {
                    clientController.registerClient(
                      firstNameController.text,
                      lastNameController.text,
                      phoneController.text,
                      emailController.text,
                      passwordController.text,
                      photoUrlController.text.isNotEmpty
                          ? photoUrlController.text
                          : null,
                      cniController.text,
                      selectedRole.value,
                    );
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
  bool _validateInputs(BuildContext context) {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        cniController.text.isEmpty) {
      Get.snackbar("Erreur", "Tous les champs obligatoires doivent être remplis.",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (passwordController.text.length != 4) {
      Get.snackbar("Erreur", "Le mot de passe doit contenir 4 chiffres.",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }
}
