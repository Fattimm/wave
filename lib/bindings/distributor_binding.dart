import 'package:get/get.dart';
import '../ui/controllers/distributor_controller.dart';
import '../services/firebase_service.dart';

class DistributorBinding extends Bindings {
  @override
  void dependencies() {
    // Enregistrer le service Firebase comme singleton
    Get.lazyPut(() => FirebaseService(), fenix: true);
    
    // Enregistrer le contrôleur du distributeur
    Get.lazyPut(() => DistributorController());
  }
}