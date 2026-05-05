import 'package:flutter/material.dart';
import 'package:mycelium/core/stores/api_store.dart';
import 'package:mycelium/viewmodels/api_viewmodel.dart';
import 'package:provider/provider.dart';

class ApiConfigPage extends StatefulWidget {
  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: context.read<ApiViewModel>().baseUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ApiViewModel>();
    final store = context.watch<ApiStore>();       
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "API Base URL",
                hintText: "http://192.168.1.10:8000",
              ),
              onSubmitted: (value) => vm.setUrl(value),
            ),
            const SizedBox(height: 16),
            if (vm.isChecking)
            const CircularProgressIndicator()
            else if (store.isReachable != null)
            Icon(
              store.isReachable! ? Icons.check_circle : Icons.cancel,
              color: store.isReachable! ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
