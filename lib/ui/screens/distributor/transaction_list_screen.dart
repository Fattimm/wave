import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/distributor_controller.dart';
import '../../../models/transaction_model.dart';
import '../../widgets/transaction_item.dart';

class DistributorTransactionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final distributorController = Get.find<DistributorController>(); // Récupérer le contrôleur

    return Scaffold(
      appBar: AppBar(title: Text("Transactions")),
      body: Obx(() { // Utiliser Obx pour réagir aux changements
        final transactions = distributorController.transactions;

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return TransactionItem(transaction: transactions[index]);
          },
        );
      }),
    );
  }
}
