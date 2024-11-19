import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final recipientController = TextEditingController();
  final amountController = TextEditingController();
  double balance = 10000.0; // Exemple de solde

  void _sendTransfer() {
    double amount = double.tryParse(amountController.text) ?? 0.0;
    double transferFee = amount * 0.01; // 1% des frais
    double totalAmount = amount + transferFee;

    if (totalAmount > balance) {
      Get.snackbar(
        "Erreur",
        "Solde insuffisant pour ce transfert.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Logique de transfert
      Get.snackbar(
        "Succès",
        "Transfert effectué à ${recipientController.text} pour ${amountController.text} FCFA",
        snackPosition: SnackPosition.BOTTOM,
      );
      // Mettre à jour le solde
      setState(() {
        balance -= totalAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfert"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: recipientController,
              decoration: InputDecoration(
                labelText: "ID du Destinataire",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Montant",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendTransfer,
              child: Text("Envoyer"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    recipientController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
