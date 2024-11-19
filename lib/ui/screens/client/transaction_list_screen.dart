import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/transaction_model.dart';
import '../../controllers/distributor_controller.dart';

class TransactionListScreen extends StatelessWidget {
  final DistributorController controller = Get.find(); // Récupérer le contrôleur

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liste des Transactions")),
      body: Obx(() {
        return ListView.builder(
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final transaction = controller.transactions[index];
            return ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text("${transaction.type} - ${transaction.amount} FCFA"),
              subtitle: Text(transaction.date),
            );
          },
        );
      }),
    );
  }
}
