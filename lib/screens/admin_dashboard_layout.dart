// Archivo: AdminDashboardLayout.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// TUS PANTALLAS REALES
import 'package:flutter_application_1/screens/inventario_screen.dart';
import 'package:flutter_application_1/screens/crear_usuario.dart';
import 'package:flutter_application_1/screens/ProveedoresScreen.dart';

// TU GRÁFICO
import 'SimpleBarChart.dart';

// COLORES
const Color sidebarColor = Color(0xFF1E2746);
const Color corporateBlue = Color(0xFF007AFF);
const Color backgroundColor = Color(0xFFF7F9FC);

// ------------------------------------------------
// PANTALLA: ACERCA DE NOSOTROS
// ------------------------------------------------
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Acerca de Nosotros",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 50,
              backgroundColor: corporateBlue,
              child: Icon(Icons.code, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "Desarrollado por:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              "Diego Marin",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: corporateBlue),
            ),
            const SizedBox(height: 10),
            const Text(
              "Plataforma de Administración Farmacéutica\nFARMA-DASH v1.0",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}


// ------------------------------------------------
// DASHBOARD PRINCIPAL
// ------------------------------------------------
class AdminDashboardLayout extends StatefulWidget {
  const AdminDashboardLayout({super.key});

  @override
  State<AdminDashboardLayout> createState() => _AdminDashboardLayoutState();
}

class _AdminDashboardLayoutState extends State<AdminDashboardLayout> {
  int selectedIndex = 0;

  // Páginas del sidebar
  late final List<Map<String, dynamic>> sidebarItems = [
    {
      'label': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'page': const AdminDashboardContent()
    },
    {
      'label': 'Inventario',
      'icon': Icons.inventory_2_outlined,
      'page': const InventarioScreen(),
    },
    {
      'label': 'Usuarios',
      'icon': Icons.people_outline,
      'page': const CrearUsuarioScreen(),
    },
    {
      'label': 'Proveedores',
      'icon': Icons.local_shipping_outlined,
      'page': const ProveedoresScreen(),
    },
    // Eliminado 'Estadísticas' aquí
    {
      'label': 'Acerca de',
      'icon': Icons.info_outline,
      'page': const AboutUsScreen()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          // ------------------------------------
          // SIDEBAR
          // ------------------------------------
          Container(
            width: 250,
            color: sidebarColor,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "FARMA-DASH",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Items del sidebar
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: sidebarItems.length,
                    itemBuilder: (context, index) {
                      return _buildSidebarItem(
                        index: index,
                        icon: sidebarItems[index]['icon'],
                        label: sidebarItems[index]['label'],
                      );
                    },
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, left: 20),
                  child: Row(
                    children: [
                      _buildFooterLink("Soporte"),
                      const SizedBox(width: 15),
                      _buildFooterLink("Privacidad"),
                    ],
                  ),
                )
              ],
            ),
          ),

          // ------------------------------------
          // CONTENIDO PRINCIPAL
          // ------------------------------------
          Expanded(
            child: Column(
              children: [
                _buildHeaderBar(context),
                Expanded(child: sidebarItems[selectedIndex]['page'])
              ],
            ),
          )
        ],
      ),
    );
  }

  // ------------------------------------------------
  // WIDGETS DEL SIDEBAR
  // ------------------------------------------------

  Widget _buildFooterLink(String text) {
    return Text(text,
        style: const TextStyle(color: Colors.white70, fontSize: 13));
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: isSelected ? corporateBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            setState(() => selectedIndex = index);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            child: Row(
              children: [
                Icon(icon,
                    color: isSelected ? Colors.white : Colors.white60,
                    size: 22),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // HEADER SUPERIOR
  // ------------------------------------------------

  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sidebarItems[selectedIndex]['label'],
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
          ),
          Row(
            children: [
              Container(
                width: 250,
                height: 40,
                margin: const EdgeInsets.only(right: 20),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFFF0F0F0),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15), // Ajuste de padding para centrar
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon:
                    const Icon(Icons.notifications_none, color: Colors.grey),
              ),
              const SizedBox(width: 15),
              const CircleAvatar(
                radius: 18,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=1'),
              )
            ],
          )
        ],
      ),
    );
  }
}

// ------------------------------------------------
// CONTENIDO DEL DASHBOARD
// ------------------------------------------------

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

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
    return StreamBuilder<int>(
      stream: contarMedicamentos(),
      builder: (context, snapMedics) {
        final totalMedics = snapMedics.data ?? 0;

        return StreamBuilder<int>(
          stream: contarPorAgotarse(),
          builder: (context, snapLow) {
            final lowStock = snapLow.data ?? 0;

            return StreamBuilder<int>(
              stream: contarUsuarios(),
              builder: (context, snapUsers) {
                final totalUsers = snapUsers.data ?? 0;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Métricas Clave",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 20),

                        // Tarjetas métricas
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 3 / 2,
                          children: [
                            _metricTile("Total Medicamentos",
                                Icons.medication, corporateBlue, totalMedics),
                            _metricTile("Por agotarse",
                                Icons.warning_amber_rounded,
                                Colors.orange.shade600,
                                lowStock),
                            _metricTile("Usuarios Registrados",
                                Icons.people_alt,
                                const Color(0xFF323B4C),
                                totalUsers),
                          ],
                        ),

                        const SizedBox(height: 40),

                        const Text("Tendencias",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 20),

                        SizedBox(
                          height: 380,
                          width: double.infinity,
                          child: SimpleBarChart(
                            totalMedics: totalMedics,
                            lowStock: lowStock,
                            totalUsers: totalUsers,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _metricTile(
      String title, IconData icon, Color color, int value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 5))
        ],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 15),
          Text("$value",
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold)),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}