import 'package:get/get.dart';
import '../ui/screens/client/login_screen.dart';
import '../ui/screens/client/home_screen.dart';
import '../ui/screens/client/client_register_screen.dart';
import '../ui/screens/client/transfer_screen.dart';
import '../ui/screens/client/multiple_transfer_screen.dart';
import '../ui/screens/client/schedule_screen.dart';
import '../ui/screens/client/client_settings_screen.dart';
import '../ui/screens/distributor/home_screen.dart';
import '../bindings/client_binding.dart';
import '../bindings/distributor_binding.dart';
import '../ui/screens/distributor/deposit_screen.dart';

class AppRoutes {
  static final routes = [
    // Routes Client
    GetPage(
      name: '/client/login',
      page: () => ClientLoginScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: '/client/home',
      page: () => ClientHomeScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: '/client/register',
      page: () => ClientRegisterScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: '/client/transfer',
      page: () => TransferScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: '/client/multiple-transfer',
      page: () => MultipleTransferScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: '/client/schedule',
      page: () => ScheduleScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: '/client/settings',
      page: () => ClientSettingsScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: '/distributor/home',
      page: () => DistributorHomeScreen(),
      binding: DistributorBinding(),
    ),
    GetPage(
      name: '/client/settings',
      page: () => ClientSettingsScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: '/distributor/deposit',
      page: () => DepositScreen(),
    ),
  ];
}
