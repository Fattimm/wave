import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:wave/services/firebase_service.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import 'auth_controller.dart';
import 'base_controller.dart';

class DistributorController extends BaseController {
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
      transactions.value = await firebaseService.getDistributorTransactions(userId);
    } catch (e) {
      print("Erreur lors de la récupération des transactions: $e");
      throw Exception("Échec du chargement des transactions");
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode spécifique au distributeur pour effectuer un dépôt
  Future<void> deposit(String recipientPhone, double amount) async {
    try {
      isLoading.value = true;

      if (authController.currentUser.value == null) {
        throw Exception('Distributeur non authentifié');
      }

      final distributor = authController.currentUser.value!;
      
      if (distributor.balance < amount) {
        throw Exception('Solde insuffisant');
      }
      
      if (distributor.balance - amount < 5000) {
        throw Exception('Le solde après dépôt serait inférieur au minimum requis (5000)');
      }

      final recipient = await firebaseService.getUserByPhone(recipientPhone);
      if (recipient == null) {
        throw Exception('Numéro de téléphone destinataire non trouvé');
      }

      final transactionData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'depot',
        'senderId': distributor.id,
        'recipientId': recipient.id,
        'senderPhone': distributor.phone,
        'recipientPhone': recipientPhone,
        'amount': amount,
        'date': Timestamp.now(),
        'senderRole': 'distributor',
        'recipientRole': recipient.role,
        'description': 'Dépôt effectué par distributeur',
        'status': 'completed',
        'initiatorPhone': distributor.phone,
        'initiatorRole': 'distributeur'
      };

      WriteBatch batch = _firestore.batch();

      final distributorRef = _firestore.collection('distributors').doc(distributor.id);
      final recipientRef = _firestore.collection(recipient.role == 'client' ? 'clients' : 'distributors').doc(recipient.id);

      // Mettre à jour le distributeur
      batch.update(distributorRef, {
        'balance': FieldValue.increment(-amount),
        'transactions': FieldValue.arrayUnion([transactionData])
      });

      // Mettre à jour le destinataire
      batch.update(recipientRef, {
        'balance': FieldValue.increment(amount),
        'transactions': FieldValue.arrayUnion([transactionData])
      });

      await batch.commit();

      // Mise à jour locale
      currentUser.value?.balance -= amount;
      currentUser.value?.transactions.add(TransactionModel.fromJson(transactionData));

      // Recharger les données de l'utilisateur
      final updatedDistributorDoc = await distributorRef.get();
      if (updatedDistributorDoc.exists) {
        currentUser.value = UserModel.fromJson(updatedDistributorDoc.data() as Map<String, dynamic>);
        await authController.saveCurrentUser(currentUser.value!);
      }

      Get.snackbar(
        'Succès',
        'Dépôt effectué avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP
      );

    } catch (e) {
      print("Erreur détaillée lors du dépôt: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors du dépôt',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour recharger les transactions
  Future<void> reloadTransactions() async {
    try {
      if (currentUser.value != null) {
        final userDoc = await _firestore
            .collection('distributors')
            .doc(currentUser.value!.id)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          currentUser.value = UserModel.fromJson(userData);
          await authController.saveCurrentUser(currentUser.value!);
        }
      }
    } catch (e) {
      print("Erreur lors du rechargement des transactions: $e");
    }
  }
}
