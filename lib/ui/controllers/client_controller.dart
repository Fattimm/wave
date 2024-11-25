import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import 'auth_controller.dart';
import 'base_controller.dart';

class ClientController extends BaseController {
  final AuthController authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  @override
  Future<void> fetchTransactions(String userId) async {
    try {
      isLoading.value = true;
      final clientTransactions =
          await firebaseService.getClientTransactions(userId);
      transactions.value = clientTransactions;
    } catch (e) {
      print("Erreur lors de la récupération des transactions: $e");
      throw Exception("Échec du chargement des transactions");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerClient(
    String firstName,
    String lastName,
    String phone,
    String email,
    String password,
    String? photoUrl,
    String cni,
    String role,
  ) async {
    try {
      UserModel? newUser = await firebaseService.registerUser(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        photoUrl: photoUrl,
        cni: cni,
        role: role,
      );

      if (newUser != null) {
        Get.snackbar("Succès", "Compte créé avec succès !");
      }
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
    }
  }

  Future<void> transfer(String recipientPhone, double amount) async {
    try {
      isLoading.value = true;

      // Vérifier l'utilisateur connecté
      if (currentUser.value == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final sender = currentUser.value!;

      // Calculer le montant total avec les frais
      double transferFee = amount * 0.01; // 1% de frais
      double totalAmount = amount + transferFee;

      // Vérifier le solde
      if (sender.balance < totalAmount) {
        throw Exception('Solde insuffisant pour effectuer ce transfert');
      }

      // Vérifier l'existence du destinataire
      final recipient = await firebaseService.getUserByPhone(recipientPhone);
      if (recipient == null) {
        throw Exception('Ce numéro n\'a pas de compte');
      }

      // Créer les données de la transaction
      final transactionData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'transfer',
        'senderId': sender.id,
        'recipientId': recipient.id,
        'senderPhone': sender.phone,
        'recipientPhone': recipientPhone,
        'amount': amount,
        'fee': transferFee,
        'totalAmount': totalAmount,
        'date': Timestamp.now(),
        'senderRole': 'client',
        'recipientRole': recipient.role,
        'description': 'Transfert entre clients',
        'status': 'completed',
        'initiatorPhone': sender.phone,
        'initiatorRole': 'client'
      };

      WriteBatch batch = _firestore.batch();

      // Références des documents
      final senderRef = _firestore.collection('clients').doc(sender.id);
      final recipientRef = _firestore
          .collection(recipient.role == 'client' ? 'clients' : 'distributors')
          .doc(recipient.id);

      // Mettre à jour l'expéditeur
      batch.update(senderRef, {
        'balance': FieldValue.increment(-totalAmount),
        'transactions': FieldValue.arrayUnion([transactionData])
      });

      // Mettre à jour le destinataire
      batch.update(recipientRef, {
        'balance': FieldValue.increment(amount),
        'transactions': FieldValue.arrayUnion([transactionData])
      });

      await batch.commit();

      // Mise à jour locale
      currentUser.value?.balance -= totalAmount;
      currentUser.value?.transactions
          .add(TransactionModel.fromJson(transactionData));

      // Recharger les données de l'utilisateur
      final updatedSenderDoc = await senderRef.get();
      if (updatedSenderDoc.exists) {
        currentUser.value =
            UserModel.fromJson(updatedSenderDoc.data() as Map<String, dynamic>);
        await authController.saveCurrentUser(currentUser.value!);
      }

      Get.snackbar('Succès', 'Transfert effectué avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      print("Erreur lors du transfert: $e");
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour recharger les transactions
  Future<void> reloadTransactions() async {
    try {
      if (currentUser.value != null) {
        final userDoc = await _firestore
            .collection('clients')
            .doc(currentUser.value!.id)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          currentUser.value = UserModel.fromJson(userData);
          await authController.saveCurrentUser(currentUser.value!);
          await fetchTransactions(currentUser.value!.id);
        }
      }
    } catch (e) {
      print("Erreur lors du rechargement des transactions: $e");
    }
  }

  Future<void> multipleTransfer(List<Map<String, dynamic>> transfers) async {
    try {
      isLoading.value = true;

      // Vérifier l'utilisateur connecté
      if (currentUser.value == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final sender = currentUser.value!;

      // Calculer le montant total nécessaire avec les frais
      double totalNeeded = 0;
      for (var transfer in transfers) {
        double amount = transfer['amount'] as double;
        double fee = amount * 0.01; // 1% de frais
        totalNeeded += (amount + fee);
      }

      // Vérifier le solde total
      if (sender.balance < totalNeeded) {
        throw Exception('Solde insuffisant pour effectuer ces transferts');
      }

      WriteBatch batch = _firestore.batch();
      List<Map<String, dynamic>> allTransactionData = [];

      // Préparer toutes les transactions
      for (var transfer in transfers) {
        String recipientPhone = transfer['phone'];
        double amount = transfer['amount'];
        double fee = amount * 0.01;
        double totalAmount = amount + fee;

        // Vérifier l'existence du destinataire
        final recipient = await firebaseService.getUserByPhone(recipientPhone);
        if (recipient == null) {
          throw Exception('Le numéro $recipientPhone n\'a pas de compte');
        }

        // Créer les données de la transaction
        final transactionData = {
          'id': '${DateTime.now().millisecondsSinceEpoch}_${recipient.id}',
          'type': 'multiple_transfer',
          'senderId': sender.id,
          'recipientId': recipient.id,
          'senderPhone': sender.phone,
          'recipientPhone': recipientPhone,
          'amount': amount,
          'fee': fee,
          'totalAmount': totalAmount,
          'date': Timestamp.now(),
          'senderRole': 'client',
          'recipientRole': recipient.role,
          'description': 'Transfert multiple',
          'status': 'completed',
          'initiatorPhone': sender.phone,
          'initiatorRole': 'client'
        };

        allTransactionData.add(transactionData);

        // Références des documents
        final recipientRef = _firestore
            .collection(recipient.role == 'client' ? 'clients' : 'distributors')
            .doc(recipient.id);

        // Mettre à jour le destinataire
        batch.update(recipientRef, {
          'balance': FieldValue.increment(amount),
          'transactions': FieldValue.arrayUnion([transactionData])
        });
      }

      // Mettre à jour l'expéditeur
      final senderRef = _firestore.collection('clients').doc(sender.id);
      batch.update(senderRef, {
        'balance': FieldValue.increment(-totalNeeded),
        'transactions': FieldValue.arrayUnion(allTransactionData)
      });

      // Exécuter toutes les transactions
      await batch.commit();

      // Mise à jour locale
      currentUser.value?.balance -= totalNeeded;
      for (var transactionData in allTransactionData) {
        currentUser.value?.transactions
            .add(TransactionModel.fromJson(transactionData));
      }

      // Recharger les données
      await reloadTransactions();

      Get.snackbar(
          'Succès', 'Tous les transferts ont été effectués avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      print("Erreur lors des transferts multiples: $e");
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
