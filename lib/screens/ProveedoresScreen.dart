import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controladores de texto para agregar/editar Proveedor
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController contactoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    contactoController.dispose();
    emailController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // UTILIDADES
  // -------------------------------------------------------
  void limpiarCampos() {
    nombreController.clear();
    contactoController.clear();
    emailController.clear();
    direccionController.clear();
  }

  void errorSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Error: $msg")),
      );
    }
  }

  // -------------------------------------------------------
  // FUNCIONES DE FIREBASE
  // -------------------------------------------------------

  // MÉTODO: AGREGAR PROVEEDOR
  Future<void> agregarProveedor() async {
    try {
      await _firestore.collection('proveedores').add({
        'nombre': nombreController.text.trim(),
        'contacto': contactoController.text.trim(),
        'email': emailController.text.trim(),
        'direccion': direccionController.text.trim(),
      });

      limpiarCampos();
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' ✅ Proveedor agregado')),
        );
      }
    } catch (e) {
      errorSnack(e.toString());
    }
  }

  // MÉTODO: EDITAR PROVEEDOR
  Future<void> editarProveedor(String id) async {
    try {
      await _firestore.collection('proveedores').doc(id).update({
        'nombre': nombreController.text.trim(),
        'contacto': contactoController.text.trim(),
        'email': emailController.text.trim(),
        'direccion': direccionController.text.trim(),
      });

      limpiarCampos();
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' ✨ Proveedor actualizado')),
        );
      }
    } catch (e) {
      errorSnack(e.toString());
    }
  }

  // MÉTODO: ELIMINAR PROVEEDOR
  Future<void> eliminarProveedor(String id) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Está seguro de que desea eliminar este proveedor?'),
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
        await _firestore.collection('proveedores').doc(id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🗑️ Proveedor eliminado')),
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
      contactoController.text = data['contacto'] ?? '';
      emailController.text = data['email'] ?? '';
      direccionController.text = data['direccion'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? "Agregar Proveedor" : "Editar Proveedor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre Comercial"),
            ),
            TextField(
              controller: contactoController,
              decoration: const InputDecoration(labelText: "Contacto / Teléfono"),
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: direccionController,
              decoration: const InputDecoration(labelText: "Dirección"),
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
              // Validar que los campos no estén vacíos
              if (nombreController.text.isEmpty ||
                  contactoController.text.isEmpty ||
                  emailController.text.isEmpty) {
                errorSnack('Nombre, contacto y email son obligatorios.');
                return;
              }

              if (docId == null) {
                agregarProveedor();
              } else {
                editarProveedor(docId);
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
      String contact,
      String email,
      String address,
      String displayId) {
    
    return Container(
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
                  backgroundColor: Colors.blueGrey.shade100,
                  child: Text(name[0].toUpperCase(),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ),
                const SizedBox(width: 8),
                Text(name),
              ],
            ),
          ),
          Expanded(
              flex: 2,
              child: Text(contact, style: const TextStyle(color: Colors.grey))),
          Expanded(
              flex: 2,
              child: Text(email, style: const TextStyle(color: Colors.grey))),
          Expanded(
              flex: 2,
              child: Text(address.isNotEmpty ? address : 'N/A', style: const TextStyle(color: Colors.black87))),
          
          // Columna de acción
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // BOTÓN EDITAR
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  onPressed: () => mostrarDialogo(
                      docId: docId,
                      data: {
                        'nombre': name,
                        'contacto': contact,
                        'email': email,
                        'direccion': address
                      }),
                ),
                // BOTÓN ELIMINAR
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => eliminarProveedor(docId),
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
  // UI PRINCIPAL (Proveedores)
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
                    "Gestión de Proveedores",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('proveedores').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        int total = snapshot.data!.docs.length;
                        return Text('Total: $total proveedores registrados',
                            style: const TextStyle(color: Colors.grey));
                      }
                      return const Text('Cargando...',
                          style: TextStyle(color: Colors.grey));
                    },
                  ),
                ],
              ),
              // Botón "Agregar Proveedor"
              ElevatedButton.icon(
                onPressed: () => mostrarDialogo(),
                icon: const Icon(Icons.person_add),
                label: const Text("Agregar Proveedor"),
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
                    // Pestaña (solo "Todo" para proveedores)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Todos los Proveedores", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
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
                              child: Text("Nombre Comercial",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          Expanded(
                              flex: 2,
                              child: Text("Contacto",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          Expanded(
                              flex: 2,
                              child: Text("Email",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          Expanded(
                              flex: 2,
                              child: Text("Dirección",
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
                        stream: _firestore.collection('proveedores').snapshots(),
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

                          if (documentos.isEmpty) {
                            return const Center(
                                child:
                                    Text('No hay proveedores registrados.'));
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
                              final String contact = data['contacto'] ?? 'N/A';
                              final String email = data['email'] ?? 'N/A';
                              final String address = data['direccion'] ?? '';
                              final String displayId = doc.id.length > 5 ? doc.id.substring(0, 5) : doc.id; // ID Corto

                              return _buildTableRow(
                                docId,
                                name,
                                contact,
                                email,
                                address,
                                '#$displayId',
                              );
                            },
                          );
                        },
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