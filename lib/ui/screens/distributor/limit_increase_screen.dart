import 'package:flutter/material.dart';

class LimitIncreaseScreen extends StatelessWidget {
  final reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demande de Déplafonnement")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(labelText: 'Motif de la demande', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ajoutez la logique pour envoyer la demande
              },
              child: Text("Envoyer la demande"),
            ),
          ],
        ),
      ),
    );
  }
}
