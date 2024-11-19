import 'package:get/get.dart';
import '../ui/controllers/client_controller.dart';
import '../services/firebase_service.dart';

class ClientBinding extends Bindings {
  @override
  void dependencies() {
    // Enregistrer le service Firebase comme singleton
    Get.lazyPut(() => FirebaseService(), fenix: true);
    
    // Enregistrer le contrôleur du client
    Get.lazyPut(() => ClientController());
  }
}