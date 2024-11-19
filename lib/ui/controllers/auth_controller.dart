import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class AuthController extends GetxController {
  final FirebaseService firebaseService = FirebaseService();

  var isLoading = false.obs; // Indique si une opération est en cours
  UserModel? currentUser; // Données de l'utilisateur connecté

  // Connexion utilisateur
  Future<void> login(String phone, String password) async {
    isLoading.value = true;

    try {
      final user = await firebaseService.getUserByPhone(phone);
      if (user != null && user.password == password) {
        currentUser = user;
        Get.snackbar("Succès", "Connexion réussie !");
        
        // Redirection en fonction du rôle
        if (user.role == 'distributeur') {
          Get.offAllNamed('/distributor/home');
        } else if (user.role == 'client') {
          Get.offAllNamed('/client/home');
        }
      } else {
        Get.snackbar("Erreur", "Numéro ou mot de passe incorrect.");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Échec de la connexion : $e");
    } finally {
      isLoading.value = false;
    }
  }
  
}
