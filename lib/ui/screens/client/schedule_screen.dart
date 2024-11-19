import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleScreen extends StatelessWidget {
  final recipientController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Planification"),
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
            SizedBox(height: 10),
            TextField(
              controller: dateController,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                labelText: "Date (JJ/MM/AAAA)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logique pour planifier le transfert
                Get.snackbar(
                  "Succès",
                  "Transfert planifié pour ${dateController.text} à ${recipientController.text}",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text("Planifier"),
            ),
          ],
        ),
      ),
    );
  }
}
