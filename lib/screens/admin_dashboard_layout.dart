import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/ProveedoresScreen.dart';
import 'inventario_screen.dart'; // Asegúrate de tener este archivo
import 'crear_usuario.dart'; // Asegúrate de tener este archivo

// Definición del color principal (el azul del sidebar de la referencia)
const Color primaryBlue = Color(0xff0B3D91);

// ------------------------------------------------
// 1. DASHBOARD PRINCIPAL (Layout con Sidebar)
// ------------------------------------------------
class AdminDashboardLayout extends StatefulWidget {
  const AdminDashboardLayout({super.key});

  @override
  State<AdminDashboardLayout> createState() => _AdminDashboardLayoutState();
}

class _AdminDashboardLayoutState extends State<AdminDashboardLayout> {
  // Inicialmente seleccionamos el Dashboard (índice 0)
  int selectedIndex = 0; 

  // Widget Placeholder para Proveedores y Estadísticas (si no existen aún)
  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        'Contenido de $title',
        style: const TextStyle(fontSize: 30, color: Colors.grey),
      ),
    );
  }

  // Mapeo de índices a etiquetas e iconos de la barra lateral
  late final List<Map<String, dynamic>> sidebarItems = [
    {'label': 'Dashboard', 'icon': Icons.dashboard_outlined, 'page': const AdminDashboardContent()}, // 0
    {'label': 'Inventario', 'icon': Icons.inventory_2_outlined, 'page': const InventarioScreen()}, // 1
    {'label': 'Usuarios', 'icon': Icons.people_outline, 'page': const CrearUsuarioScreen()}, // 2
    {'label': 'Proveedores', 'icon': Icons.local_shipping_outlined, 'page': const ProveedoresScreen()}, // 3 - NUEVO
    {'label': 'Estadísticas', 'icon': Icons.bar_chart_outlined, 'page': _buildPlaceholder('Estadísticas')}, // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ------------------------------------
          // SIDEBAR (Barra Lateral)
          // ------------------------------------
          Container(
            width: 250,
            color: primaryBlue,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "FARMA-DASH",
                  style: TextStyle(
                      fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
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
                // Footer de la barra lateral
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, left: 20),
                  child: Row(
                    children: [
                      _buildSocialLink("Soporte"),
                      const SizedBox(width: 8),
                      _buildSocialLink("Privacidad"),
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
                // BARRA SUPERIOR (Header)
                _buildHeaderBar(context),

                // CONTENIDO DE LA PÁGINA SELECCIONADA
                Expanded(child: sidebarItems[selectedIndex]['page'] as Widget),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget para construir los enlaces del footer
  Widget _buildSocialLink(String text) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12));
  }

  // Widget para construir la barra superior (Header)
  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sidebarItems[selectedIndex]['label'] as String,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.grey)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.grey)),
              const SizedBox(width: 15),
              const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para construir cada Item de la Barra Lateral
  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = selectedIndex == index;

    // Decoración del ítem seleccionado (la curva blanca y la sombra)
    final BoxDecoration selectedDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withOpacity(0.5),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Container(
          decoration: isSelected ? selectedDecoration : null,
          child: Container(
            // Contenedor interno para el espaciado
            margin: isSelected ? const EdgeInsets.only(left: 4) : const EdgeInsets.only(left: 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: isSelected
                ? const BoxDecoration(
                    color: Colors.white, // Fondo blanco para el ítem activo
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  )
                : null,
            child: Row(
              children: [
                Icon(icon,
                    color: isSelected ? primaryBlue : Colors.white70, size: 22),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                        color: isSelected ? primaryBlue : Colors.white70,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------
// 2. CONTENIDO DEL DASHBOARD (Métricas de Farmacia)
// ------------------------------------------------
class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  // Streams de datos (tomados de tu código original)
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métricas de Inventario y Usuarios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            
            // Fila de Métricas Principales (3 Columnas)
            GridView.count(
              crossAxisCount: 3, 
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 25,
              mainAxisSpacing: 25,
              children: [
                // 🔵 TOTAL MEDICAMENTOS
                _buildMetricCard(
                  titulo: "Total Medicamentos",
                  icono: Icons.medication,
                  color: Colors.blue.shade700,
                  stream: contarMedicamentos(),
                ),

                // 🟠 POR AGOTARSE
                _buildMetricCard(
                  titulo: "Por agotarse (<5)",
                  icono: Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  stream: contarPorAgotarse(),
                ),

                // 🟢 USUARIOS REGISTRADOS
                _buildMetricCard(
                  titulo: "Usuarios Registrados",
                  icono: Icons.people,
                  color: Colors.green.shade700,
                  stream: contarUsuarios(),
                ),
              ],
            ),
            
            const SizedBox(height: 40),

            // ------------------------------------
            // BLOQUE DE ACCIONES RÁPIDAS (3 Botones)
            // ------------------------------------
            const Text(
              'Acciones Rápidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // 🟣 BOTÓN VER INVENTARIO
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    titulo: "Ver Inventario",
                    icono: Icons.list_alt,
                    color: Colors.purple.shade700,
                    indexToSelect: 1, // Inventario
                  ),
                ),
                const SizedBox(width: 25),

                // 🔴 BOTÓN CREAR USUARIO
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    titulo: "Crear Usuario",
                    icono: Icons.person_add_alt_1,
                    color: Colors.red.shade700,
                    indexToSelect: 2, // Usuarios
                  ),
                ),
                const SizedBox(width: 25), // Espacio entre los 3 botones
                
                // 🟤 BOTÓN PROVEEDORES
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    titulo: "Proveedores",
                    icono: Icons.local_shipping,
                    color: Colors.brown.shade700,
                    indexToSelect: 3, // Proveedores
                  ),
                ),
              ],
            ),
            // Puedes añadir un espacio vertical si quieres más contenido debajo
            const SizedBox(height: 40), 

            // Ejemplo de una tarjeta grande para Añadir Producto (como un acceso destacado)
            _buildQuickAddCard(context),
            const SizedBox(height: 30), 
          ],
        ),
      ),
    );
  }

  // Widget Destacado para Añadir Producto (solicitado implícitamente)
  Widget _buildQuickAddCard(BuildContext context) {
    final layoutState = context.findAncestorStateOfType<_AdminDashboardLayoutState>();

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Añadir Nuevo Medicamento Rápido',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                'Acceso directo a la página de ingreso de inventario.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar al inventario (índice 1) y esperar que desde allí se añada
              if (layoutState != null) {
                layoutState.setState(() {
                  layoutState.selectedIndex = 1; 
                });
              }
            },
            icon: const Icon(Icons.add_box, color: primaryBlue),
            label: const Text('AÑADIR PRODUCTO', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )
        ],
      ),
    );
  }

  // Widget para construir las tarjetas de métricas con StreamBuilder
  Widget _buildMetricCard({
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, size: 40, color: Colors.white),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$valor",
                    style: const TextStyle(
                        fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    titulo,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para construir los botones de acción (cambia el contenido principal)
  Widget _buildActionButton({
    required BuildContext context,
    required String titulo,
    required IconData icono,
    required Color color,
    required int indexToSelect,
  }) {
    final layoutState = context.findAncestorStateOfType<_AdminDashboardLayoutState>();

    return InkWell(
      onTap: () {
        if (layoutState != null) {
          // Cambiamos el índice de la barra lateral, lo que refresca el contenido principal.
          layoutState.setState(() {
            layoutState.selectedIndex = indexToSelect;
          });
        }
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 30, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: const TextStyle(
                    fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}