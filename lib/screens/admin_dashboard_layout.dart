import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'inventario_screen.dart';
import 'crear_usuario.dart';

class AdminDashboardLayout extends StatefulWidget {
  const AdminDashboardLayout({super.key});

  @override
  State<AdminDashboardLayout> createState() => _AdminDashboardLayoutState();
}

class _AdminDashboardLayoutState extends State<AdminDashboardLayout> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    AdminDashboard(),     // Dashboard principal
    InventarioScreen(),   // Inventario
    Placeholder(),        // Ventas (se hará)
    Placeholder(),        // Proveedores
    Placeholder(),        // Alertas
    Placeholder(),        // Reportes
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ------------------------------------
          // SIDEBAR
          // ------------------------------------
          Container(
            width: 250,
            color: const Color(0xff0B3D91),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "FarmaSystem",
                  style: TextStyle(
                      fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Sistema de Inventario",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),

                sidebarItem(
                    index: 0,
                    icon: Icons.dashboard_outlined,
                    label: "Inicio / Dashboard"),

                sidebarItem(
                    index: 1, icon: Icons.inventory_2_outlined, label: "Inventario"),

                sidebarItem(
                    index: 2, icon: Icons.shopping_cart_outlined, label: "Ventas"),

                sidebarItem(
                    index: 3, icon: Icons.local_shipping_outlined, label: "Proveedores"),

                sidebarItem(
                    index: 4, icon: Icons.warning_amber_rounded, label: "Alertas"),

                sidebarItem(
                    index: 5, icon: Icons.bar_chart_outlined, label: "Reportes"),
              ],
            ),
          ),

          // ------------------------------------
          // CONTENIDO
          // ------------------------------------
          Expanded(
            child: Column(
              children: [
                // BARRA SUPERIOR
                Container(
                  height: 70,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getPageTitle(),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text("Usuario Admin",
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Farmacia Central",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(width: 10),
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.blue,
                            child: Text(
                              "UA",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // CONTENIDO PRINCIPAL
                Expanded(child: pages[selectedIndex]),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ------------------------------------------------
  // SIDEBAR ITEM
  // ------------------------------------------------
  Widget sidebarItem(
      {required int index,
      required IconData icon,
      required String label}) {
    final bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.white70, size: 22),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // TÍTULO DEL CONTENIDO
  // ------------------------------------------------
  String getPageTitle() {
    switch (selectedIndex) {
      case 0:
        return "Inicio / Dashboard";
      case 1:
        return "Inventario";
      case 2:
        return "Ventas";
      case 3:
        return "Proveedores";
      case 4:
        return "Alertas";
      case 5:
        return "Reportes";
      default:
        return "";
    }
  }
}
