import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BalanceWidget extends StatelessWidget {
  final RxBool isVisible;
  final double balance;

  BalanceWidget({required this.isVisible, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Text(
              isVisible.value ? "Solde: $balance FCFA" : "Solde: ****",
              style: TextStyle(fontSize: 24),
            )),
        ElevatedButton(
          onPressed: () => isVisible.value = !isVisible.value,
          child: Obx(() => Text(isVisible.value ? "Cacher" : "Afficher")),
        ),
      ],
    );
  }
}
