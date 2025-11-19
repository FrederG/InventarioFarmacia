import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  // Controladores de texto para agregar/editar
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    nombreController.dispose();
    cantidadController.dispose();
    precioController.dispose();
    fechaController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // UTILIDADES
  // -------------------------------------------------------
  void limpiarCampos() {
    nombreController.clear();
    cantidadController.clear();
    precioController.clear();
    fechaController.clear();
  }

  void errorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(" Error: $msg")),
    );
  }

  // -------------------------------------------------------
  // FUNCIONES DE FIREBASE
  // -------------------------------------------------------

  // MÉTODO: AGREGAR MEDICAMENTO
  Future<void> agregarMedicamento() async {
    try {
      await _firestore.collection('medicamentos').add({
        'nombre': nombreController.text.trim(),
        'cantidad': int.parse(cantidadController.text.trim()),
        'precio': double.parse(precioController.text.trim()),
        'fechaVencimiento': fechaController.text.trim(),
      });

      limpiarCampos();
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Medicamento agregado')),
        );
      }
    } catch (e) {
      errorSnack(e.toString());
    }
  }

  // MÉTODO: EDITAR MEDICAMENTO
  Future<void> editarMedicamento(String id) async {
    try {
      await _firestore.collection('medicamentos').doc(id).update({
        'nombre': nombreController.text.trim(),
        'cantidad': int.parse(cantidadController.text.trim()),
        'precio': double.parse(precioController.text.trim()),
        'fechaVencimiento': fechaController.text.trim(),
      });

      limpiarCampos();
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Medicamento actualizado')),
        );
      }
    } catch (e) {
      errorSnack(e.toString());
    }
  }

  // MÉTODO: ELIMINAR MEDICAMENTO
  Future<void> eliminarMedicamento(String id) async {
    // Implementación más completa: mostrar un diálogo de confirmación antes de eliminar
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Está seguro de que desea eliminar este medicamento?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('medicamentos').doc(id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🗑️ Medicamento eliminado')),
          );
        }
      } catch (e) {
        errorSnack(e.toString());
      }
    }
  }

  // -------------------------------------------------------
  // DIALOGO PARA AGREGAR O EDITAR
  // -------------------------------------------------------
  void mostrarDialogo({String? id, Map<String, dynamic>? data, String? docId}) {
    // Limpiar campos por defecto
    limpiarCampos();
    // Si es edición, llenamos los campos con los datos actuales
    if (data != null) {
      nombreController.text = data['nombre'] ?? '';
      // Asumimos que 'cantidad' y 'precio' son números, pero se muestran como texto
      cantidadController.text = data['cantidad']?.toString() ?? '';
      precioController.text = data['precio']?.toString() ?? '';
      fechaController.text = data['fechaVencimiento'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(docId == null ? "Agregar medicamento" : "Editar medicamento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cantidad"),
            ),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Precio"),
            ),
            TextField(
              controller: fechaController,
              decoration:
                  const InputDecoration(labelText: "Fecha de vencimiento"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              limpiarCampos();
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              // Validar que los campos no estén vacíos antes de guardar/actualizar
              if (nombreController.text.isEmpty ||
                  cantidadController.text.isEmpty ||
                  precioController.text.isEmpty ||
                  fechaController.text.isEmpty) {
                errorSnack('Todos los campos son obligatorios.');
                return;
              }

              if (docId == null) {
                agregarMedicamento();
              } else {
                editarMedicamento(docId);
              }
            },
            child: Text(docId == null ? "Guardar" : "Actualizar"),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // WIDGET DE LA FILA DE LA TABLA
  // -------------------------------------------------------
  Widget _buildTableRow(
      String docId,
      String name,
      int quantity,
      String expirationDate,
      double price,
      String displayId) {
    // Simular el estado de entrega con color basado en la cantidad (stock bajo)
    String status = quantity < 100 ? 'Low Stock' : 'In Stock';
    Color statusColor = Colors.grey;
    if (quantity < 100) {
      statusColor = Colors.red;
      status = 'Low Stock';
    } else {
      statusColor = Colors.green;
      status = 'In Stock';
    }

    // Simula el resaltado azul (desactivado para no confundir con datos reales)
    final bool isSelected = false;

    return Container(
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(displayId))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Avatar simulado con la primera letra del nombre
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(name[0],
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ),
                const SizedBox(width: 8),
                Text(name,
                    style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
          Expanded(
              flex: 3,
              child:
                  Text(expirationDate, style: const TextStyle(color: Colors.grey))),
          Expanded(
              flex: 1,
              child: Text(quantity.toString(),
                  style: const TextStyle(color: Colors.grey))),
          Expanded(
              flex: 1, child: Text('\$${price.toStringAsFixed(2)}')),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(status,
                      style: TextStyle(color: statusColor, fontSize: 12)),
                ),
              ],
            ),
          ),
          // Columna de acción con ícono de configuración para Editar/Eliminar
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // BOTÓN EDITAR (Simulado con ícono de configuración)
                IconButton(
                  icon: const Icon(Icons.settings,
                      size: 18, color: Colors.blueGrey),
                  onPressed: () => mostrarDialogo(
                      docId: docId,
                      data: {
                        'nombre': name,
                        'cantidad': quantity,
                        'precio': price,
                        'fechaVencimiento': expirationDate
                      }),
                ),
                // BOTÓN ELIMINAR (Simulado con ícono de flecha hacia abajo)
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => eliminarMedicamento(docId),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // WIDGET DE PAGINACIÓN (Simulación visual)
  // -------------------------------------------------------
  Widget _buildPageButton(String text, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12),
      ),
    );
  }

  // -------------------------------------------------------
  // UI PRINCIPAL (Contenido "Order" adaptado a "Inventario")
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y conteo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Inventario de Medicamentos",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  // El conteo se actualizará dentro del StreamBuilder
                  const Text(
                    "Cargando...",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              // Botón "Add Order" (Adaptado a "Agregar Medicamento")
              ElevatedButton.icon(
                onPressed: () => mostrarDialogo(),
                icon: const Icon(Icons.add),
                label: const Text("Agregar Medicamento"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tarjeta que contiene la tabla
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pestañas (Simulación visual)
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: const [
                        Tab(text: "Todo"),
                        Tab(text: "Stock Bajo"),
                        Tab(text: "Vencimiento Cercano"),
                        Tab(text: "Activo"),
                      ],
                    ),
                    const Divider(height: 1, color: Colors.grey),

                    // Encabezados de la tabla
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                      child: Row(
                        children: const [
                          Expanded(
                              flex: 1,
                              child: Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text("Id",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)))),
                          Expanded(
                              flex: 2,
                              child: Text("Nombre",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          Expanded(
                              flex: 3,
                              child: Text("Fecha Vencimiento",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          Expanded(
                              flex: 1,
                              child: Text("Cantidad",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          Expanded(
                              flex: 1,
                              child: Text("Precio",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          Expanded(
                              flex: 1,
                              child: Text("Estado",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          Expanded(
                              flex: 1,
                              child: Text("Acción",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.grey),

                    // Cuerpo de la tabla con datos de Firebase
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('medicamentos').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          final documentos = snapshot.data!.docs;

                          // **Actualiza el conteo en el título**
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              // Esto es una adaptación simplificada para actualizar el conteo,
                              // en una aplicación real, probablemente usarías un StateNotifier/Provider o un StatelessWidget
                              // para manejar el estado fuera del StreamBuilder del ListView.
                              (context as Element).markNeedsBuild();
                            }
                          });

                          if (documentos.isEmpty) {
                            return const Center(
                                child:
                                    Text('No hay medicamentos registrados.'));
                          }

                          return ListView.separated(
                            itemCount: documentos.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final doc = documentos[index];
                              final data = doc.data() as Map<String, dynamic>;

                              // Mapeo de datos para la fila
                              final String docId = doc.id;
                              final String name = data['nombre'] ?? 'N/A';
                              final int quantity =
                                  (data['cantidad'] is num) ? data['cantidad'].toInt() : 0;
                              final double price =
                                  (data['precio'] is num) ? data['precio'].toDouble() : 0.0;
                              final String expirationDate =
                                  data['fechaVencimiento'] ?? 'N/A';
                              final String displayId = doc.id.length > 5 ? doc.id.substring(0, 5) : doc.id; // ID Corto

                              return _buildTableRow(
                                docId,
                                name,
                                quantity,
                                expirationDate,
                                price,
                                '#$displayId',
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Paginación (simulación visual)
                    const Divider(height: 1, color: Colors.grey),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Mostrando 1-10 de N'),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.keyboard_arrow_left, size: 20),
                                const SizedBox(width: 10),
                                _buildPageButton('1', isSelected: true),
                                _buildPageButton('2', isSelected: false),
                                _buildPageButton('3', isSelected: false),
                                const SizedBox(width: 10),
                                const Icon(Icons.keyboard_arrow_right, size: 20),
                              ],
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
        ],
      ),
    );
  }
}