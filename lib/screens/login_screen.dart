import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_home.dart';
import 'cajero_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Usuario no encontrado");

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) throw Exception("Usuario no registrado en Firestore");

      final rol = doc['rol'];

      if (rol == "ADMIN") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminHome()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const CajeroHome()));
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --------------------------------------------------------
          // FONDO AZUL CON CURVAS
          // --------------------------------------------------------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B4DFF),
                  Color(0xFF0039CB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Curvas suaves usando Opacity
          Positioned(
            top: -80,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(200),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(300),
              ),
            ),
          ),

          // --------------------------------------------------------
          // FORMULARIO LOGIN
          // --------------------------------------------------------
         Center(
  child: Container(
    width: 420,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12), // Transparente tipo glass
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.shopping_cart_outlined,
          size: 90,
          color: Colors.white,
        ),
        const SizedBox(height: 40),

        // USERNAME
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.2),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white.withOpacity(0.05),
          ),
          child: TextField(
            controller: emailController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "USERNAME",
              hintStyle: TextStyle(color: Colors.white70),
              icon: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // PASSWORD
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.2),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white.withOpacity(0.05),
          ),
          child: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "PASSWORD",
              hintStyle: TextStyle(color: Colors.white70),
              icon: Icon(Icons.lock, color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (errorMessage != null)
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.redAccent),
          ),

        const SizedBox(height: 20),

        // BOTÓN LOGIN
        SizedBox(
          width: 250,
          height: 45,
          child: ElevatedButton(
            onPressed: isLoading ? null : login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.blue)
                : const Text(
                    "LOGIN",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),

        const SizedBox(height: 15),

        const Text(
          "Forgot password?",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    ),
  ),
),

        ],
      ),
    );
  }
}
