import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrearUsuarioScreen extends StatefulWidget {
  const CrearUsuarioScreen({super.key});

  @override
  State<CrearUsuarioScreen> createState() => _CrearUsuarioScreenState();
}

class _CrearUsuarioScreenState extends State<CrearUsuarioScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String rolSeleccionado = 'CAJERO'; // valor por defecto
  bool isLoading = false;
  String? mensaje;

  // Color principal (el azul del sidebar)
  static const Color primaryBlue = Color(0xff0B3D91);

  Future<void> crearUsuario() async {
    setState(() {
      isLoading = true;
      mensaje = null;
    });

    try {
      // 1️⃣ Crear el usuario en Firebase Authentication
      UserCredential credenciales = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      final uid = credenciales.user!.uid;

      // 2️⃣ Guardar en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nombre': nombreController.text.trim(),
        'email': emailController.text.trim(),
        'rol': rolSeleccionado,
        'uid': uid,
      });

      setState(() {
        mensaje = "✅ Usuario creado correctamente";
      });

      // Limpiar los campos
      nombreController.clear();
      emailController.clear();
      passwordController.clear();
      rolSeleccionado = 'CAJERO';
    } on FirebaseAuthException catch (e) {
      setState(() {
        mensaje = "⚠️ Error: ${e.message}";
      });
    } catch (e) {
      setState(() {
        mensaje = "⚠️ Error inesperado: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Fondo gris claro para destacar la tarjeta
      
      // La AppBar es simple, ya que se espera que el Layout principal la maneje
      // Pero si se usa esta pantalla de forma independiente, esta AppBar funciona
      appBar: AppBar(
        title: const Text('Crear Usuario'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Suponemos que la navegación la maneja el Layout
      ),
      body: Center(
        // Añadimos más Padding alrededor para que no se vea pegado al borde
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: SizedBox(
            width: 450, // Ligeramente más ancho para mejor distribución
            child: Container(
              // Usamos Container con BoxDecoration para tener control total del sombreado
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Sombra más sutil y suave
                    blurRadius: 10,
                    offset: const Offset(0, 4), // Desplazamiento hacia abajo
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Registrar nuevo usuario",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue), // Título en color azul
                    ),
                    const SizedBox(height: 30),
                    
                    // --- Campo Nombre ---
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: const Icon(Icons.person, color: primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- Campo Correo ---
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: const Icon(Icons.email, color: primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- Campo Contraseña ---
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock, color: primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- Dropdown Rol ---
                    DropdownButtonFormField<String>(
                      value: rolSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Rol del usuario',
                        prefixIcon: const Icon(Icons.security, color: primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'CAJERO', child: Text('Cajero ')),
                        DropdownMenuItem(
                            value: 'ADMIN', child: Text('Administrador ')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          rolSeleccionado = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 30),

                    // --- Botón Crear Usuario ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : crearUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue, // Fondo azul para el botón
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Crear usuario",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),

                    // --- Mensaje de Estado ---
                    if (mensaje != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        mensaje!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: mensaje!.contains("✅")
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w600),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}