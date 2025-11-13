import 'package:flutter/material.dart';
import 'crear_usuario.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Administrador')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bienvenido Administrador 👑'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CrearUsuarioScreen()));
              },
              child: const Text("Crear nuevo usuario"),
            ),
          ],
        ),
      ),
    );
  }
}
