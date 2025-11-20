import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

// Enum para representar los diferentes filtros del inventario
enum InventarioFiltro {
  todo,
  stockBajo,
  vencimientoCercano,
}

class _InventarioScreenState extends State<InventarioScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  InventarioFiltro _filtroActual = InventarioFiltro.todo; // Estado de filtro

  // Controladores de texto para agregar/editar
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  // Constante para el umbral de stock bajo
  static const int _stockBajoUmbral = 100;
  // Constante para el umbral de vencimiento (60 días)
  static const int _vencimientoUmbralDias = 60;

  @override
  void initState() {
    super.initState();
    // Se ajusta la longitud del TabController a 3 (Todo, Stock Bajo, Vencimiento Cercano)
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    nombreController.dispose();
    cantidadController.dispose();
    precioController.dispose();
    fechaController.dispose();
    super.dispose();
  }

  // Maneja el cambio de pestaña y actualiza el filtro
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }
    setState(() {
      switch (_tabController.index) {
        case 0:
          _filtroActual = InventarioFiltro.todo;
          break;
        case 1:
          _filtroActual = InventarioFiltro.stockBajo;
          break;
        case 2:
          _filtroActual = InventarioFiltro.vencimientoCercano;
          break;
        default:
          _filtroActual = InventarioFiltro.todo;
          break;
      }
    });
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Error: $msg")),
      );
    }
  }

  // Utilidad para PARSEAR la fecha asumiendo formato dd/MM/yyyy
  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;

      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      // Asume que el año es de 4 dígitos.
      final year = int.tryParse(parts[2]); 

      if (day == null || month == null || year == null) return null;

      // Crea un objeto DateTime usando los componentes (Año, Mes, Día)
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  // -------------------------------------------------------
  // FUNCIONES DE FIREBASE
  // -------------------------------------------------------

  // Genera la consulta de Firebase (Siempre devuelve todos los documentos para filtrar en cliente)
  Stream<QuerySnapshot> _getInventoryStream() {
    // Como el filtrado por stock y por fecha de vencimiento es complejo en Firestore
    // con un solo campo, cargamos toda la colección y filtramos en el cliente.
    return _firestore.collection('medicamentos').snapshots();
  }

  // MÉTODO: AGREGAR MEDICAMENTO
  Future<void> agregarMedicamento() async {
    try {
      int cantidad = int.parse(cantidadController.text.trim());
      double precio = double.parse(precioController.text.trim());

      await _firestore.collection('medicamentos').add({
        'nombre': nombreController.text.trim(),
        'cantidad': cantidad,
        'precio': precio,
        'fechaVencimiento': fechaController.text.trim(), // Formato dd/MM/yyyy
      });

      limpiarCampos();
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' ✅ Medicamento agregado')),
        );
      }
    } catch (e) {
      errorSnack(e.toString());
    }
  }

  // MÉTODO: EDITAR MEDICAMENTO
  Future<void> editarMedicamento(String id) async {
    try {
      int cantidad = int.parse(cantidadController.text.trim());
      double precio = double.parse(precioController.text.trim());

      await _firestore.collection('medicamentos').doc(id).update({
        'nombre': nombreController.text.trim(),
        'cantidad': cantidad,
        'precio': precio,
        'fechaVencimiento': fechaController.text.trim(),
      });

      limpiarCampos();
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' ✨ Medicamento actualizado')),
        );
      }
    } catch (e) {
      errorSnack(e.toString());
    }
  }

  // MÉTODO: ELIMINAR MEDICAMENTO
  Future<void> eliminarMedicamento(String id) async {
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
  void mostrarDialogo({String? docId, Map<String, dynamic>? data}) {
    // Limpiar campos por defecto
    limpiarCampos();
    // Si es edición, llenamos los campos con los datos actuales
    if (data != null) {
      nombreController.text = data['nombre'] ?? '';
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
              keyboardType: TextInputType.datetime, // Para fechas
              decoration: const InputDecoration(
                  labelText: "Fecha de vencimiento (dd/MM/yyyy)"),
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

              // Validación de números
              if (int.tryParse(cantidadController.text.trim()) == null ||
                  double.tryParse(precioController.text.trim()) == null) {
                errorSnack('Cantidad y Precio deben ser números válidos.');
                return;
              }

              // Validación de fecha (usando el parseo simple)
              if (_parseDate(fechaController.text.trim()) == null) {
                 errorSnack('El formato de fecha debe ser dd/MM/yyyy válido.');
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
    // Lógica para determinar el estado de Stock
    String status = '';
    Color statusColor = Colors.grey;

    if (quantity < _stockBajoUmbral) {
      statusColor = Colors.red;
      status = 'Low Stock';
    } else {
      statusColor = Colors.green;
      status = 'In Stock';
    }

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
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
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
          // Columna de acción
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // BOTÓN EDITAR
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
                // BOTÓN ELIMINAR
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
  // UI PRINCIPAL (Contenido "Inventario")
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
                  // Conteo
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('medicamentos').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<QueryDocumentSnapshot> todos = snapshot.data!.docs;
                        
                        // Aplicamos el mismo filtro del cuerpo de la lista para obtener el conteo correcto
                        if (_filtroActual != InventarioFiltro.todo) {
                           final now = DateTime.now();
                           final vencimientoUmbral = now.add(const Duration(days: _vencimientoUmbralDias)); 
                           
                           todos = todos.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final int quantity = (data['cantidad'] is num) ? data['cantidad'].toInt() : 0;
                              final String expirationDateStr = data['fechaVencimiento'] ?? '';

                              if (_filtroActual == InventarioFiltro.stockBajo) {
                                return quantity < _stockBajoUmbral;
                              } 
                              
                              if (_filtroActual == InventarioFiltro.vencimientoCercano) {
                                final expirationDate = _parseDate(expirationDateStr);
                                // Filtra si la fecha no es nula y está dentro del umbral
                                return expirationDate != null && expirationDate.isBefore(vencimientoUmbral);
                              }

                              return true;
                           }).toList();
                        }

                        int totalFiltrado = todos.length;
                        return Text('Total: $totalFiltrado medicamentos',
                            style: const TextStyle(color: Colors.grey));
                      }
                      return const Text('Cargando...',
                          style: TextStyle(color: Colors.grey));
                    },
                  ),
                ],
              ),
              // Botón "Agregar Medicamento"
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
                    // Pestañas
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
                        stream: _getInventoryStream(),
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

                          List<QueryDocumentSnapshot> documentos = snapshot.data!.docs;

                          // ---------------------------------------------------
                          // LÓGICA DE FILTRADO EN EL CLIENTE
                          // ---------------------------------------------------
                          if (_filtroActual != InventarioFiltro.todo) {
                            final now = DateTime.now();
                            // Medicamentos que vencen en 60 días o menos
                            final vencimientoUmbral = now.add(const Duration(days: _vencimientoUmbralDias)); 
                            
                            documentos = documentos.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final int quantity = (data['cantidad'] is num) ? data['cantidad'].toInt() : 0;
                              final String expirationDateStr = data['fechaVencimiento'] ?? '';

                              if (_filtroActual == InventarioFiltro.stockBajo) {
                                return quantity < _stockBajoUmbral;
                              } 
                              
                              if (_filtroActual == InventarioFiltro.vencimientoCercano) {
                                final expirationDate = _parseDate(expirationDateStr);
                                // Filtra si la fecha no es nula y es anterior o igual al umbral de vencimiento
                                return expirationDate != null && expirationDate.isBefore(vencimientoUmbral);
                              }

                              return true;
                            }).toList();
                          }
                          // ---------------------------------------------------

                          if (documentos.isEmpty) {
                            return const Center(
                                child:
                                    Text('No hay medicamentos registrados para este filtro.'));
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