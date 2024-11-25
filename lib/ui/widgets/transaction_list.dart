import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';

class TransactionsList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel)? onTransactionTap;
  final bool isLoading;

  const TransactionsList({
    Key? key,
    required this.transactions,
    this.onTransactionTap,
    this.isLoading = false,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatAmount(double amount) {
    final numberFormat = NumberFormat.currency(
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    return numberFormat.format(amount);
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.depot:
        return Icons.arrow_downward;
      case TransactionType.retrait:
        return Icons.arrow_upward;
      case TransactionType.transfert:
        return Icons.swap_horiz;
      case TransactionType.transfertMultiple:
        return Icons.people;
      case TransactionType.transfertPlanifie:
        return Icons.schedule;
      case TransactionType.depotInitial:
        return Icons.account_balance;
      case TransactionType.deplafonnement:
        return Icons.upgrade;
      default:
        return Icons.monetization_on;
    }
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.depot:
      case TransactionType.depotInitial:
        return Colors.green;
      case TransactionType.retrait:
        return Colors.red;
      case TransactionType.transfert:
      case TransactionType.transfertMultiple:
        return Colors.blue;
      case TransactionType.transfertPlanifie:
        return Colors.orange;
      case TransactionType.deplafonnement:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTransactionTitle(TransactionModel transaction) {
    switch (transaction.type) {
      case TransactionType.depot:
        return 'Dépôt';
      case TransactionType.retrait:
        return 'Retrait';
      case TransactionType.transfert:
        return 'Transfert';
      case TransactionType.transfertMultiple:
        return 'Transfert Multiple';
      case TransactionType.transfertPlanifie:
        return 'Transfert Planifié';
      case TransactionType.depotInitial:
        return 'Dépôt Initial';
      case TransactionType.deplafonnement:
        return 'Déplafonnement';
      default:
        return 'Transaction';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "Aucune transaction disponible",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final transactionColor = _getTransactionColor(transaction.type);
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: transactionColor.withOpacity(0.1),
            child: Icon(
              _getTransactionIcon(transaction.type),
              color: transactionColor,
            ),
          ),
          title: Row(
            children: [
              Text(
                _getTransactionTitle(transaction),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: transactionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: transactionColor,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                _formatAmount(transaction.amount),
                style: TextStyle(
                  color: transactionColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(transaction.date),
                style: const TextStyle(fontSize: 12),
              ),
              if (transaction.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  transaction.description!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          onTap: onTransactionTap != null
              ? () => onTransactionTap!(transaction)
              : null,
        );
      },
    );
  }
}