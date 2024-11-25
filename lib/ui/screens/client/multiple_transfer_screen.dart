import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/client_controller.dart';

class MultipleTransferScreen extends StatefulWidget {
  @override
  _MultipleTransferScreenState createState() => _MultipleTransferScreenState();
}

class _MultipleTransferScreenState extends State<MultipleTransferScreen> {
  final ClientController _controller = Get.find<ClientController>();
  final List<TextEditingController> phoneControllers = [];
  final List<TextEditingController> amountControllers = [];
  final _formKey = GlobalKey<FormState>();
  bool isProcessing = false;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addRecipient();
  }

  void _addRecipient() {
    phoneControllers.add(TextEditingController());
    amountControllers.add(TextEditingController());
    setState(() {});
  }

  void _removeRecipient(int index) {
    if (phoneControllers.length > 1) {
      phoneControllers[index].dispose();
      amountControllers[index].dispose();
      phoneControllers.removeAt(index);
      amountControllers.removeAt(index);
      setState(() {});
    }
  }

  Future<void> _processTransfers() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isProcessing = true);

    try {
      List<Map<String, dynamic>> transfers = [];

      for (int i = 0; i < phoneControllers.length; i++) {
        transfers.add({
          'phone': phoneControllers[i].text.trim(),
          'amount': double.parse(amountControllers[i].text),
        });
      }

      await _controller.multipleTransfer(transfers);

      Get.back(); // Retourner à l'écran précédent après succès
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfert Multiple"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: phoneControllers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTransferField(
                                      controller: phoneControllers[index],
                                      label: "Téléphone ${index + 1}",
                                      icon: Icons.phone,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Numéro requis';
                                        }
                                        if (value.length != 9) {
                                          return 'Numéro invalide';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    color: Colors.red,
                                    onPressed: () => _removeRecipient(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildTransferField(
                                controller: amountControllers[index],
                                label: "Montant (FCFA)",
                                icon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Montant requis';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
                                    return 'Montant invalide';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _addRecipient();
                            // Scroll to bottom after adding new recipient
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Ajouter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing ? null : _processTransfers,
                          icon: isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(isProcessing ? "Envoi..." : "Envoyer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransferField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade900),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
