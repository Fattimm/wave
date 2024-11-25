import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BalanceWidget extends StatelessWidget {
  final RxBool isVisible;
  final double balance;

  const BalanceWidget({
    Key? key,
    required this.isVisible,
    required this.balance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
          isVisible.value 
              ? "Solde: ${balance.toStringAsFixed(2)} FCFA" 
              : "Solde: ****",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )),
        ElevatedButton(
          onPressed: () => isVisible.value = !isVisible.value,
          child: Obx(() => Text(isVisible.value ? "Cacher" : "Afficher")),
        ),
      ],
    );
  }
}
