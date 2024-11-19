import 'package:get/get.dart';
import '../../models/transaction_model.dart';
import '../../services/firebase_service.dart';
import 'auth_controller.dart';
import '../../models/user_model.dart';

class ClientController extends GetxController {
  final FirebaseService firebaseService = FirebaseService();
  final AuthController authController = Get.find<AuthController>();

  var balanceVisible = false.obs; // État pour afficher/cacher le solde
  var isLoading = false.obs; // Indique si une opération est en cours
  var transactions = <TransactionModel>[].obs; // Liste des transactions

  UserModel? currentUser; // Données de l'utilisateur connecté

  // Charger les transactions pour l'utilisateur connecté
  Future<void> loadTransactions(String userId) async {
    isLoading.value = true;

    try {
      final userTransactions = await firebaseService.getClientTransactions(userId);
      transactions.value = userTransactions;
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de charger les transactions : $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Basculer l'affichage du solde
  void toggleBalanceVisibility() {
    balanceVisible.value = !balanceVisible.value;
  }

  // Méthode pour enregistrer un utilisateur (client ou distributeur)
  Future<void> registerClient(
    String firstName,
    String lastName,
    String phone,
    String email,
    String password,
    String? photo,
    String cni,
    String role,
  ) async {
    isLoading.value = true;

    try {
      final collectionName = role == 'client' ? 'clients' : 'distributors';
      final newId = await firebaseService.getNextId(collectionName);

      final newUser = UserModel(
        id: newId.toString(),
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
        photo: photo,
        cni: cni,
        role: role,
        balance: 0.0, // Solde initial
      );

      await firebaseService.addUserToCollection(collectionName, newUser);

      Get.snackbar(
        "Succès",
        "$role enregistré avec succès avec l'ID $newId.",
        snackPosition: SnackPosition.BOTTOM,
      );

      if (role == "client") {
        Get.offAllNamed('/client/home');
      } else if (role == "distributeur") {
        Get.offAllNamed('/distributor/home');
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Échec de l'enregistrement : $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
