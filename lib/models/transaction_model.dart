class TransactionModel {
  final String id; // Identifiant unique de la transaction
  final String type; // Type de transaction : transfert, retrait, dépôt
  final String senderId; // ID de l'utilisateur envoyant (ou null pour un dépôt)
  final String recipientId; // ID du destinataire (ou null pour un retrait)
  final double amount; // Montant de la transaction
  final String date; // Date au format ISO (YYYY-MM-DD HH:mm:ss)
  final String role; // Rôle de l'utilisateur (client ou distributeur)

  TransactionModel({
    required this.id,
    required this.type,
    required this.senderId,
    required this.recipientId,
    required this.amount,
    required this.date,
    required this.role, // Ajout de la propriété rôle
  });

  // Convertir JSON en TransactionModel
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      amount: (json['amount'] as num).toDouble(),
      date: json['date'],
      role: json['role'], // Récupération du rôle
    );
  }

  // Convertir TransactionModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'senderId': senderId,
      'recipientId': recipientId,
      'amount': amount,
      'date': date,
      'role': role, // Ajout de la propriété rôle
    };
  }
}
