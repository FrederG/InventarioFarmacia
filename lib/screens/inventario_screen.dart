import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();

  // -------------------------------------------------------
  // MÉTODO: AGREGAR MEDICAMENTO
  // -------------------------------------------------------
  Future<void> agregarMedicamento() async {
    try {
      await _firestore.collection('medicamentos').add({
        'nombre': nombreController.text.trim(),
        'cantidad': int.parse(cantidadController.text.trim()),
        'precio': double.parse(precioController.text.trim()),
        'fechaVencimiento': fechaController.text.trim(),
      });

      limpiarCampos();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Medicamento agregado')),
      );
    } catch (e) {
      errorSnack(e.toString());
    }
  }

  // -------------------------------------------------------
  // MÉTODO: EDITAR MEDICAMENTO
  // -------------------------------------------------------
  Future<void> editarMedicamento(String id) async {
    try {
      await _firestore.collection('medicamentos').doc(id).update({
        'nombre': nombreController.text.trim(),
        'cantidad': int.parse(cantidadController.text.trim()),
        'precio': double.parse(precioController.text.trim()),
        'fechaVencimiento': fechaController.text.trim(),
      });

      limpiarCampos();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✏️ Medicamento actualizado')),
      );
    } catch (e) {
      errorSnack(e.toString());
    }
  }

  // -------------------------------------------------------
  // MÉTODO: ELIMINAR MEDICAMENTO
  // -------------------------------------------------------
  Future<void> eliminarMedicamento(String id) async {
    await _firestore.collection('medicamentos').doc(id).delete();
  }

  // -------------------------------------------------------
  // DIALOGO PARA AGREGAR O EDITAR
  // -------------------------------------------------------
  void mostrarDialogo({String? id, Map<String, dynamic>? data}) {
    // Si es edición, llenamos los campos con los datos actuales
    if (data != null) {
      nombreController.text = data['nombre'];
      cantidadController.text = data['cantidad'].toString();
      precioController.text = data['precio'].toString();
      fechaController.text = data['fechaVencimiento'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? "Agregar medicamento" : "Editar medicamento"),
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
              if (id == null) {
                agregarMedicamento();
              } else {
                editarMedicamento(id);
              }
            },
            child: Text(id == null ? "Guardar" : "Actualizar"),
          ),
        ],
      ),
    );
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
      SnackBar(content: Text("⚠️ Error: $msg")),
    );
  }

  // -------------------------------------------------------
  // UI PRINCIPAL
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario 💊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => mostrarDialogo(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('medicamentos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final medicamentos = snapshot.data!.docs;

          if (medicamentos.isEmpty) {
            return const Center(child: Text('No hay medicamentos registrados'));
          }

          return ListView.builder(
            itemCount: medicamentos.length,
            itemBuilder: (context, index) {
              final doc = medicamentos[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['nombre']),
                  subtitle: Text(
                      'Cantidad: ${data['cantidad']} | Precio: \$${data['precio']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // BOTÓN EDITAR ✏️
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => mostrarDialogo(id: doc.id, data: data),
                      ),
                      // BOTÓN ELIMINAR 🗑️
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => eliminarMedicamento(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
