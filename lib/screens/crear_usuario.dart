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
      appBar: AppBar(
        title: const Text('Crear Usuario'),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Registrar nuevo usuario",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                        labelText: 'Nombre', prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: 'Correo', prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: rolSeleccionado,
                    items: const [
                      DropdownMenuItem(
                          value: 'CAJERO', child: Text('Cajero 💊')),
                      DropdownMenuItem(
                          value: 'ADMIN', child: Text('Administrador 👑')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        rolSeleccionado = value!;
                      });
                    },
                    decoration: const InputDecoration(
                        labelText: 'Rol del usuario',
                        prefixIcon: Icon(Icons.security)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : crearUsuario,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Crear usuario"),
                  ),
                  if (mensaje != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      mensaje!,
                      style: TextStyle(
                          color: mensaje!.contains("✅")
                              ? Colors.green
                              : Colors.red),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
