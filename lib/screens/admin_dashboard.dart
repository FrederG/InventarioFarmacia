import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inventario_screen.dart';
import 'crear_usuario.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Stream<int> contarMedicamentos() {
    return FirebaseFirestore.instance
        .collection('medicamentos')
        .snapshots()
        .map((snap) => snap.size);
  }

  Stream<int> contarPorAgotarse() {
    return FirebaseFirestore.instance
        .collection('medicamentos')
        .where('cantidad', isLessThan: 5)
        .snapshots()
        .map((snap) => snap.size);
  }

  Stream<int> contarUsuarios() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snap) => snap.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Administrador 👑"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            // 🔵 TOTAL MEDICAMENTOS
            dashboardCard(
              titulo: "Total Medicamentos",
              icono: Icons.medication,
              color: Colors.blue,
              stream: contarMedicamentos(),
            ),

            // 🟠 POR AGOTARSE
            dashboardCard(
              titulo: "Por agotarse (<5)",
              icono: Icons.warning_amber_rounded,
              color: Colors.orange,
              stream: contarPorAgotarse(),
            ),

            // 🟢 USUARIOS REGISTRADOS
            dashboardCard(
              titulo: "Usuarios Registrados",
              icono: Icons.people,
              color: Colors.green,
              stream: contarUsuarios(),
            ),

            // 🟣 BOTÓN VER INVENTARIO
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventarioScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    "Ver Inventario",
                    style: TextStyle(
                        fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // 🔴 BOTÓN CREAR USUARIO
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrearUsuarioScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    "Crear Usuario",
                    style: TextStyle(
                        fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // WIDGET TARJETA DEL DASHBOARD
  // -------------------------------------------------------
  Widget dashboardCard({
    required String titulo,
    required IconData icono,
    required Color color,
    required Stream<int> stream,
  }) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final valor = snapshot.data ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  "$valor",
                  style: const TextStyle(
                      fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
