import 'package:get/get.dart';
import '../../models/deposit_model.dart';
import '../../models/transaction_model.dart';
import '../../services/firebase_service.dart';
import 'auth_controller.dart';
import '../../models/user_model.dart';

class DistributorController extends GetxController {
  final FirebaseService firebaseService = FirebaseService();
  final AuthController authController = Get.find<AuthController>();

  var balanceVisible = false.obs;
  var isLoading = false.obs;
  var transactions = <TransactionModel>[].obs;
  UserModel? currentUser;

  // Charger les données du distributeur
  Future<void> initializeDistributorData() async {
    isLoading.value = true;

    try {
      await loadBalance();
      await loadTransactions();
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de charger les données : $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Charger le solde
  // Charger le solde
Future<void> loadBalance() async {
  isLoading.value = true;

  try {
    if (authController.currentUser == null) {
      throw Exception("Utilisateur non authentifié");
    }

    final user = await firebaseService.getUserByPhone(authController.currentUser!.phone);
    if (user != null) {
      currentUser = user;
      // Si nécessaire, mettre à jour la balance dans `currentUser`
    }
  } catch (e) {
    Get.snackbar("Erreur", "Impossible de charger le solde : $e");
  } finally {
    isLoading.value = false;
  }
}


  // Charger les transactions
  Future<void> loadTransactions() async {
    isLoading.value = true;

    try {
      if (authController.currentUser != null) {
        final userTransactions = await firebaseService.getDistributorTransactions(
          authController.currentUser!.id,
        );
        transactions.assignAll(userTransactions);
      }
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de charger les transactions : $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Effectuer un dépôt
  Future<void> makeDeposit(String clientId, double amount, String method) async {
    if (!validateAmount(amount)) return;
    if (!await isClientActive(clientId)) return;

    isLoading.value = true;

    try {
      final deposit = DepositModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        distributorId: authController.currentUser!.id,
        clientId: clientId,
        amount: amount,
        method: method,
        date: DateTime.now().toIso8601String(),
      );
      await firebaseService.addDeposit(deposit);
      await addTransaction('Dépôt', amount, authController.currentUser!.id, clientId, 'distributeur');
      Get.snackbar("Succès", "Dépôt de $amount FCFA effectué pour le client $clientId");
    } catch (e) {
      Get.snackbar("Erreur", "Impossible d'effectuer le dépôt : $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Vérifier si un montant est valide
  bool validateAmount(double amount) {
    if (amount <= 0) {
      Get.snackbar("Erreur", "Le montant doit être supérieur à zéro.");
      return false;
    }
    return true;
  }

  // Vérifier si un client est actif
  Future<bool> isClientActive(String clientId) async {
    try {
      final user = await firebaseService.getUserByPhone(clientId);
      if (user != null && user.etat == 'actif') {
        return true;
      }
      Get.snackbar("Erreur", "Le compte du client est désactivé.");
      return false;
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de vérifier l'état du client : $e");
      return false;
    }
  }

  // Basculer la visibilité de la balance
  void toggleBalanceVisibility() {
    balanceVisible.value = !balanceVisible.value;
  }

  Future<void> addTransaction(String type, double amount, String senderId,
      String recipientId, String role) async {
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      senderId: senderId,
      recipientId: recipientId,
      amount: amount,
      date: DateTime.now().toIso8601String(),
      role: role,
    );
    await firebaseService.addTransaction(transaction);
  }

}
