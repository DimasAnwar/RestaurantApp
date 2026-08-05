import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';

class RegistPage extends StatefulWidget {
  const RegistPage({ Key? key }) : super(key: key);

  @override
  _RegistPageState createState() => _RegistPageState();
}

class _RegistPageState extends State<RegistPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 1. WAJIB TAMBAHIN DISPOSE
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Samain sama AppBar biar mulus
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Bikin AppBar gak ada bayangannya (lebih modern)
        iconTheme: const IconThemeData(color: Colors.black), // Warna tombol back otomatis hitam
      ),
      
      // 2. BUNGKUS PAKAI SingleChildScrollView BIAR AMAN DARI KEYBOARD
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24), // Diganti 24 biar margin kiri-kanan lebih lega
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 28, // Besarin dikit biar kerasa Header-nya
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8), // Kasih jarak dikit antara Judul dan Sub-judul
              
              const Text(
                "Join FlavorFlow and elevate your dining experience.",
                style: TextStyle(color: Colors.grey), // Sub-judul dikasih warna abu-abu biar elegan
              ),
              const SizedBox(height: 40),
              
              CustomInput(
                label: "Email", 
                hint: "jhondoe@gmail.com", 
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              
              CustomInput(
                label: "Username", 
                hint: "jhondoe", 
                controller: _usernameController,
              ),
              const SizedBox(height: 20),
              
              CustomInput(
                label: "Password", 
                hint: "*******", 
                isPassword: true, // 3. JANGAN LUPA NYALAIN SENSOR PASSWORDNYA
                controller: _passwordController,
              ),
              
              const SizedBox(height: 40), // Jarak ke tombol dibesarin dikit
              
              // Bungkus CustomButton pakai SizedBox.expand / Center biar full width kalau diperlukan,
              // tapi karena di dalam CustomButton udah ada MediaQuery width 85%, aman.
              Center(
                child: CustomButton(
                  text: "Sign Up", 
                  onPressed: (){
                    print("Email: ${_emailController.text}");
                    print("Username: ${_usernameController.text}");
                    print("Password: ${_passwordController.text}");
                  }
                ),
              ),
              
              const SizedBox(height: 20), // Jarak antara tombol utama dan teks login
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an Account?"),
                  TextButton(
                    onPressed: (){
                      // 4. KASIH LOGIKA BUAT BALIK KE HALAMAN LOGIN
                      Navigator.pushReplacementNamed(context, '/login');
                    }, 
                    child: const Text(
                      "LogIn",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}