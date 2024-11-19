import 'package:flutter/material.dart';

class WithdrawalScreen extends StatelessWidget {
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Effectuer un retrait")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Montant', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ajoutez la logique pour effectuer un retrait
              },
              child: Text("Confirmer le retrait"),
            ),
          ],
        ),
      ),
    );
  }
}
