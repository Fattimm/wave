import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.monetization_on),
      title: Text("${transaction.type} - ${transaction.amount} FCFA"),
      subtitle: Text(transaction.date),
    );
  }
}
