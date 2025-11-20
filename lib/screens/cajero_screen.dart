import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

// --- COLORES BASADOS EN EL PATRÓN DE ADMINISTRADOR ---
const Color _sidebarColor = Color(0xFF1E2746);
const Color _corporateBlue = Color(0xFF007AFF); // Color de acento
const Color _backgroundColor = Color(0xFFF7F9FC);
const Color _dangerColor = Colors.red;
const Color _successColor = Colors.green;
// ----------------------------------------------------

class CajeroScreen extends StatefulWidget {
  const CajeroScreen({super.key});

  @override
  State<CajeroScreen> createState() => _CajeroScreenState();
}

class _CajeroScreenState extends State<CajeroScreen> {
  // --- LÓGICA MANTENIDA INTACTA ---
  List<Map<String, dynamic>> carrito = [];
  double _montoRecibido = 0.0;
  final TextEditingController _searchController = TextEditingController();

  void agregarAlCarrito(Map<String, dynamic> producto) {
    final index = carrito.indexWhere((item) => item['id'] == producto['id']);

    if (index == -1) {
      carrito.add({...producto, 'cantidadCarrito': 1});
    } else {
      if (carrito[index]['cantidadCarrito'] < producto['cantidad']) {
        carrito[index]['cantidadCarrito']++;
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Stock insuficiente")));
      }
    }
    setState(() {});
  }

  void cambiarCantidad(int index, int delta) {
    final item = carrito[index];
    final nuevaCantidad = item['cantidadCarrito'] + delta;

    if (nuevaCantidad <= 0) {
      carrito.removeAt(index);
    } else if (nuevaCantidad <= item['cantidad']) {
      item['cantidadCarrito'] = nuevaCantidad;
    }
    setState(() {});
  }

  double calcularTotal() {
    return carrito.fold(0.0,
        (total, p) => total + ((p['precio'] ?? 0.0) * (p['cantidadCarrito'] ?? 0)));
  }

  double calcularCambio() {
    final cambio = _montoRecibido - calcularTotal();
    return cambio > 0 ? cambio : 0.0;
  }

  Future<void> generarPdfFactura(Map<String, dynamic> venta) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("FARMA-DASH",
                  style: pw.TextStyle(
                      fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text("Factura de Venta",
                  style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 15),

              pw.Text("Fecha: ${DateTime.now()}"),
              pw.SizedBox(height: 10),

              pw.Divider(),

              pw.Text("Productos:", style: pw.TextStyle(fontSize: 16)),

              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("Producto",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("Cant",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text("Total",
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),

                  ...venta["items"].map<pw.TableRow>((p) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(p["nombre"])),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text("${p["cantidadVendida"]}")),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                                "\$${(p["precio"] * p["cantidadVendida"]).toStringAsFixed(2)}")),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),

              pw.Text("Total a pagar: \$${venta["total"].toStringAsFixed(2)}",
                  style:
                      pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text("Monto recibido: \$${venta["montoRecibido"].toStringAsFixed(2)}"),
              pw.Text("Cambio devuelto: \$${venta["cambioDevuelto"].toStringAsFixed(2)}"),

              pw.SizedBox(height: 20),
              pw.Text("Gracias por su compra ❤️",
                  style: pw.TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (format) async => pdf.save()); // Descarga en navegador
  }

  Future<void> procesarVenta() async {
    if (carrito.isEmpty) return;

    final total = calcularTotal();
    if (_montoRecibido < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Monto recibido insuficiente")),
      );
      return;
    }

    final venta = {
      "fecha": Timestamp.now(),
      "total": total,
      "montoRecibido": _montoRecibido,
      "cambioDevuelto": calcularCambio(),
      "items": carrito
          .map((p) => {
                "id": p["id"],
                "nombre": p["nombre"],
                "precio": p["precio"],
                "cantidadVendida": p["cantidadCarrito"],
              })
          .toList(),
    };

    final batch = FirebaseFirestore.instance.batch();
    batch.set(FirebaseFirestore.instance.collection("ventas").doc(), venta);

    for (var item in carrito) {
      final doc = FirebaseFirestore.instance.collection("medicamentos").doc(item["id"]);
      final nuevoStock = item["cantidad"] - item["cantidadCarrito"];
      batch.update(doc, {"cantidad": nuevoStock});
    }

    await batch.commit();

    // Generar PDF local
    await generarPdfFactura(venta);

    // Limpiar UI
    setState(() {
      carrito.clear();
      _montoRecibido = 0;
      _searchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Venta completada y PDF generado")),
    );
  }
  // --- FIN LÓGICA MANTENIDA INTACTA ---

  // ---------------------------------------------------------------------
  // --------------------------- UI CON ESTILO ADMIN ---------------------
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  // Sidebar (Patrón Admin)
  Widget _buildSidebar() {
    return Container(
      width: 250, // Ligeramente más ancho
      color: _sidebarColor,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text("FARMA-DASH",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          _buildSidebarItem(Icons.point_of_sale, "Punto de Venta", true, () {
            // Actualmente en esta pantalla
          }),
          
          const Spacer(), // Empuja "Cerrar Sesión" hacia abajo
          
          _buildSidebarItem(Icons.logout, "Cerrar Sesión", false, () async {
            // Lógica de cierre de sesión: desloguear y navegar a Login
            try {
              await FirebaseAuth.instance.signOut();
            } catch (e) {
              // Si falla el signOut, mostramos un mensaje pero igual intentamos navegar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al cerrar sesión: $e')),
              );
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Item de Sidebar (Patrón Admin)
  Widget _buildSidebarItem(
      IconData icon, String text, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Material(
        color: selected ? _corporateBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            child: Row(
              children: [
                Icon(icon,
                    color: selected ? Colors.white : Colors.white60, size: 22),
                const SizedBox(width: 15),
                Text(
                  text,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white60,
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Contenido Principal
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildProductPanel()),
          const SizedBox(width: 25),
          Expanded(flex: 2, child: _buildCartPanel()),
        ],
      ),
    );
  }

  // Panel de Productos (Estilo Admin)
  Widget _buildProductPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de Búsqueda (Estilo profesional)
        Container(
          height: 50,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Buscar producto...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 25),
        const Text("Inventario",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("medicamentos")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              final products = snapshot.data!.docs.where((p) =>
                  (p["nombre"] ?? "")
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase())).toList();

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  final cantidad = (p["cantidad"] ?? 0);
                  final precio = (p["precio"] ?? 0.0).toDouble();
                  final bool outOfStock = cantidad <= 0;
                  
                  // Resaltar stock bajo/agotado
                  Color stockColor = _successColor;
                  if (cantidad <= 10 && cantidad > 0) {
                      stockColor = Colors.orange;
                  } else if (outOfStock) {
                      stockColor = _dangerColor;
                  }
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(p["nombre"], style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Row(
                        children: [
                          Text("Stock: $cantidad - ", style: TextStyle(color: stockColor, fontWeight: FontWeight.w500)),
                          Text(outOfStock ? "Agotado" : "Disponible", style: TextStyle(color: stockColor)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Text("\$${precio.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _corporateBlue)),
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart, color: _corporateBlue),
                            onPressed: outOfStock ? null : () {
                              agregarAlCarrito({
                                "id": p.id,
                                "nombre": p["nombre"],
                                "precio": precio,
                                "cantidad": cantidad, // Stock disponible total
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: outOfStock ? null : () {
                         agregarAlCarrito({
                          "id": p.id,
                          "nombre": p["nombre"],
                          "precio": precio,
                          "cantidad": cantidad,
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  // Panel del Carrito (Estilo profesional/limpio)
  Widget _buildCartPanel() {
    final total = calcularTotal();
    final cambio = calcularCambio();

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
             BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 5)
            ),
          ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Detalle del Carrito",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: carrito.length,
              itemBuilder: (_, i) {
                final item = carrito[i];
                final precioTotalLinea = (item["precio"] ?? 0.0) * (item["cantidadCarrito"] ?? 0);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // Nombre y precio unitario
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["nombre"], style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text("\$${(item["precio"] ?? 0.0).toStringAsFixed(2)} c/u", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      
                      // Controles de Cantidad
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: () => cambiarCantidad(i, -1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("${item['cantidadCarrito']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () => cambiarCantidad(i, 1),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 15),
                      // Total por Línea
                      SizedBox(
                        width: 80,
                        child: Text(
                          "\$${precioTotalLinea.toStringAsFixed(2)}", 
                          textAlign: TextAlign.right, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 30),
          
          // Total
          _buildTotalRow('TOTAL A PAGAR', total, fontSize: 32, isBold: true, color: _corporateBlue),
          
          const SizedBox(height: 25),

          // Monto Recibido
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Monto recibido (\$)",
              hintText: '0.00',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
            onChanged: (v) =>
                setState(() => _montoRecibido = double.tryParse(v) ?? 0),
          ),

          const SizedBox(height: 15),
          
          // Cambio a Devolver (Estilo profesional)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: _successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _successColor.withOpacity(0.3))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cambio a Devolver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _successColor)),
                Text(
                  '\$${cambio.toStringAsFixed(2)}', 
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _successColor)
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),

          // Botón Finalizar Venta
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _successColor,
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 3,
              ),
              onPressed: total > 0 && _montoRecibido >= total
                  ? procesarVenta
                  : null,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
              label: const Text("FINALIZAR VENTA",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper para las filas de resumen (Estilo profesional)
  Widget _buildTotalRow(
  String label,
  double amount, {
  double fontSize = 16,
  Color color = Colors.black,
  bool isBold = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        
        // ---------- TEXTO IZQUIERDO (TOTAL A PAGAR) ----------
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,  // 🎯 Ajusta automáticamente
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ---------- VALOR A LA DERECHA ----------
        FittedBox(
          fit: BoxFit.scaleDown, // 🎯 Evita desbordarse
          child: Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}
} 