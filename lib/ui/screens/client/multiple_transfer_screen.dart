import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultipleTransferScreen extends StatefulWidget {
  @override
  _MultipleTransferScreenState createState() => _MultipleTransferScreenState();
}

class _MultipleTransferScreenState extends State<MultipleTransferScreen> {
  final List<TextEditingController> recipientControllers = [];
  final List<TextEditingController> amountControllers = [];
  double balance = 10000.0; // Exemple de solde

  @override
  void initState() {
    super.initState();
    _addRecipient();
  }

  void _addRecipient() {
    recipientControllers.add(TextEditingController());
    amountControllers.add(TextEditingController());
    setState(() {});
  }

  void _removeRecipient(int index) {
    if (recipientControllers.length > 1) {
      recipientControllers.removeAt(index);
      amountControllers.removeAt(index);
      setState(() {});
    }
  }

  void _sendTransfers() {
    for (int i = 0; i < recipientControllers.length; i++) {
      String recipientId = recipientControllers[i].text;
      double amount = double.tryParse(amountControllers[i].text) ?? 0.0;
      double transferFee = amount * 0.01; // 1% des frais
      double totalAmount = amount + transferFee;

      if (totalAmount > balance) {
        Get.snackbar(
          "Erreur",
          "Solde insuffisant pour le transfert à $recipientId.",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print("Transfert de $amount FCFA à $recipientId");
        // Mettre à jour le solde
        balance -= totalAmount;
      }
    }

    Get.snackbar(
      "Succès",
      "Transferts effectués !",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfert Multiple"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: recipientControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: recipientControllers[index],
                            decoration: InputDecoration(
                              labelText: "ID Destinataire ${index + 1}",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: amountControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Montant",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeRecipient(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addRecipient,
              child: Text("Ajouter Destinataire"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendTransfers,
              child: Text("Envoyer Tous"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in recipientControllers) {
      controller.dispose();
    }
    for (var controller in amountControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
