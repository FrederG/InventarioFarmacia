import 'package:flutter/material.dart';

class CajeroHome extends StatelessWidget {
  const CajeroHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Cajero')),
      body: const Center(child: Text('Bienvenido Cajero 💊')),
    );
  }
}
