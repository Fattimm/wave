// Énumération pour les types de transaction
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  depot,
  retrait,
  deplafonnement,
  transfert,
  transfertMultiple,
  transfertPlanifie,
  depotInitial
}

// Énumération pour les rôles
enum UserRole {
  client,
  distributeur
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final String initiatorPhone; // Numéro de celui qui fait la transaction
  final String? recipientPhone; // Numéro du destinataire (peut être null pour certains types)
  final double amount;
  final DateTime date;
  final UserRole initiatorRole;
  final String status; // 'pending', 'completed', 'failed'
  final String? description;
  final Map<String, dynamic>? additionalData; // Pour les données spécifiques à certains types
  
  TransactionModel({
    required this.id,
    required this.type,
    required this.initiatorPhone,
    this.recipientPhone,
    required this.amount,
    required this.date,
    required this.initiatorRole,
    this.status = 'completed',
    this.description,
    this.additionalData, required String recipientId, required String senderId, required String senderPhone, required String senderRole, required String recipientRole,
  });

  // Constructeur spécifique pour le dépôt initial
  factory TransactionModel.initialDeposit({
    required String initiatorPhone,
    required UserRole role,
  }) {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.depotInitial,
      initiatorPhone: initiatorPhone,
      amount: 0.0,
      date: DateTime.now(),
      initiatorRole: role,
      description: 'Dépôt initial à la création du compte', recipientId: '', senderId: '', senderPhone: '', senderRole: '', recipientRole: '',
    );
  }

  // Constructeur pour les transferts multiples
  factory TransactionModel.multipleTransfer({
    required String initiatorPhone,
    required List<String> recipientPhones,
    required double amountPerRecipient,
    DateTime? scheduledDate,
  }) {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.transfertMultiple,
      initiatorPhone: initiatorPhone,
      amount: amountPerRecipient * recipientPhones.length,
      date: scheduledDate ?? DateTime.now(),
      initiatorRole: UserRole.client,
      additionalData: {
        'recipients': recipientPhones,
        'amountPerRecipient': amountPerRecipient,
      },recipientId: '', senderId: '', senderPhone: '', senderRole: '', recipientRole: '',
    );
  }

  // Constructeur pour les transferts planifiés
  factory TransactionModel.scheduledTransfer({
    required String initiatorPhone,
    required String recipientPhone,
    required double amount,
    required DateTime scheduledDate,
  }) {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.transfertPlanifie,
      initiatorPhone: initiatorPhone,
      recipientPhone: recipientPhone,
      amount: amount,
      date: scheduledDate,
      initiatorRole: UserRole.client,
      status: 'pending',
      additionalData: {
        'scheduledDate': scheduledDate.toIso8601String(),
      },recipientId: '', senderId: '', senderPhone: '', senderRole: '', recipientRole: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'initiatorPhone': initiatorPhone,
      'recipientPhone': recipientPhone,
      'amount': amount,
      'date': date.toIso8601String(),
      'initiatorRole': initiatorRole.toString(),
      'status': status,
      'description': description,
      'additionalData': additionalData,
    };
  }

  // factory TransactionModel.fromJson(Map<String, dynamic> json) {
  //   return TransactionModel(
  //     id: json['id'],
  //     type: TransactionType.values.firstWhere(
  //       (e) => e.toString() == json['type'],
  //     ),
  //     initiatorPhone: json['initiatorPhone'],
  //     recipientPhone: json['recipientPhone'],
  //     amount: json['amount'].toDouble(),
  //     date: DateTime.parse(json['date']),
  //     initiatorRole: UserRole.values.firstWhere(
  //       (e) => e.toString() == json['initiatorRole'],
  //     ),
  //     status: json['status'],
  //     description: json['description'],
  //     additionalData: json['additionalData'], recipientId: '', senderId: '', senderPhone: '', senderRole: '', recipientRole: '',
  //   );
  // }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
  try {
    return TransactionModel(
      id: json['id'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'], 
        orElse: () => TransactionType.depot,
      ),
      initiatorPhone: json['initiatorPhone'],
      recipientPhone: json['recipientPhone'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: (json['date'] is Timestamp)
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
      initiatorRole: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['initiatorRole'],
        orElse: () => UserRole.client,
      ),
      status: json['status'] ?? 'completed',
      description: json['description'],
      additionalData: json['additionalData'],
      senderId: json['senderId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      senderPhone: json['senderPhone'] ?? '',
      senderRole: json['senderRole'] ?? '',
      recipientRole: json['recipientRole'] ?? '',
    );
  } catch (e) {
    print('Erreur lors de la désérialisation de TransactionModel: $e');
    print('JSON reçu: $json');
    rethrow;
  }
}

}
