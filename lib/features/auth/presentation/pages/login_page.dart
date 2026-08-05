import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Kasih warna background dasar
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity, 
            // Tambahin tinggi minimal seukuran layar biar tetap bisa ke tengah
            // walau dibungkus SingleChildScrollView
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_dining, 
                  size: 60,
                  color: AppColors.primary,
                ),
                const Text(
                  "Magic Food",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24, // Besarin dikit biar kerasa judulnya
                    fontWeight: FontWeight.bold
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    // height: 400 dihapus biar tingginya dinamis
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Dibikin lebih soft shadow-nya
                          spreadRadius: 2,
                          blurRadius: 15, // Blur dilebarin biar makin elegan
                          offset: const Offset(0, 5),
                        )
                      ]
                    ),
                    child : Padding(
                      padding: const EdgeInsets.all(24), // Diganti dari EdgeInsetsGeometry
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700, // Diganti dari FontWeight(700)
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500, // Diganti dari FontWeight(400)
                            ),
                          ),
                          const SizedBox(height: 8), // Kasih jarak dikit antara label dan input
                          CustomInput(
                            label: "Email",
                            hint: "Jhondoe@gmail.com",
                            isPassword: false, 
                            controller: _emailController, 
                          ),
                          
                          const SizedBox(height: 20),
                          
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomInput(
                            label: "Password",
                            hint: "*********",
                            isPassword: true, 
                            controller: _passwordController, 
                          ),
                          
                          // Bikin Lupa Password rata kanan biar estetik
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: (){},
                              child: const Text("Lupa Password?", style: TextStyle(color: AppColors.primary)),
                            ),
                          ),

                          const SizedBox(height: 10), // Jarak sebelum tombol

                          CustomButton(
                            text: "Login", 
                            onPressed: (){
                              Navigator.pushNamed(context, '/dashboard');
                            }
                          ),                  
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}