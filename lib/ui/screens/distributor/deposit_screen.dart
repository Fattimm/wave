import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/distributor_controller.dart';

class DepositScreen extends StatelessWidget {
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final DistributorController distributorController = Get.find<DistributorController>();
  final formKey = GlobalKey<FormState>();

  DepositScreen({Key? key}) : super(key: key);

  // Validation du numéro de compte
  String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de compte est requis';
    }
    if (value.length < 8) {
      return 'Le numéro de compte doit contenir au moins 8 chiffres';
    }
    return null;
  }

  // Validation du montant
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Veuillez entrer un montant valide';
    }
    if (amount < 1000) {
      return 'Le montant minimum de dépôt est de 1000 FCFA';
    }
    return null;
  }

  // Fonction pour effectuer le dépôt
  void handleDeposit() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        // Vérifier le solde avant de commencer
        final currentBalance = distributorController.authController.currentUser.value?.balance ?? 0;
        final amount = double.parse(amountController.text);
        
        if (currentBalance <= 5000) {
          Get.snackbar(
            'Erreur',
            'Solde insuffisant pour effectuer des dépôts (minimum 5000 FCFA requis)',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        if (currentBalance < amount) {
          Get.snackbar(
            'Erreur',
            'Solde insuffisant pour effectuer ce dépôt',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        Get.dialog(
          const Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
        );

        final String accountNumber = accountNumberController.text;
        await distributorController.deposit(accountNumber, amount);

        Get.back(); // Fermer le dialogue de chargement
        Get.snackbar(
          'Succès',
          'Dépôt effectué avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        accountNumberController.clear();
        amountController.clear();

        await Future.delayed(const Duration(seconds: 2));
        Get.back(); // Retourner à l'écran précédent
      } catch (e) {
        Get.back(); // Fermer le dialogue de chargement
        Get.snackbar(
          'Erreur',
          'Une erreur est survenue lors du dépôt: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    }
  }

  Widget _buildBalanceCard() {
    return Obx(() {
      final distributor = distributorController.authController.currentUser.value;
      final balance = distributor?.balance ?? 0.0;
      final isLowBalance = balance <= 5000;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Votre solde actuel",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${balance.toStringAsFixed(0)} FCFA",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isLowBalance ? Colors.red : Colors.green,
                ),
              ),
              if (isLowBalance)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Solde insuffisant pour effectuer des dépôts",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDepositForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: accountNumberController,
          decoration: const InputDecoration(
            labelText: "Numéro de Compte",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          keyboardType: TextInputType.number,
          validator: validateAccountNumber,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: "Montant",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.money),
            suffixText: 'FCFA',
          ),
          keyboardType: TextInputType.number,
          validator: validateAmount,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: handleDeposit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Faire un Dépôt",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Notes importantes:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '- Le montant minimum de dépôt est de 1000 FCFA\n'
              '- Vous devez avoir plus de 5000 FCFA dans votre compte pour effectuer des dépôts',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dépôt"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 16),
                _buildDepositForm(),
                const SizedBox(height: 16),
                _buildInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
