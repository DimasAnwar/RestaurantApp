import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';
import '../../../admin/pages/admin_dashboard_page.dart';
import '../../../dashboard/presentation/pages/main_dashboard_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

    Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email dan Password wajib diisi!')),
        );
        return;
      }

      // 1. Simpan hasil auth ke dalam variabel AuthResponse
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        // 2. Ambil data user dari variabel 'res' di atas
        final user = res.user;
        final role = user?.userMetadata?['role'] ?? 'customer';
        
        // 3. Logic navigasi (sudah bersih dari titik koma nyasar)
        if (role == 'admin') {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const MainDashboardPage()),
          );
        }
        // (Navigasi '/dashboard' ganda sudah dihapus)
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan tak terduga'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity, 
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
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), 
                          spreadRadius: 2,
                          blurRadius: 15, 
                          offset: const Offset(0, 5),
                        )
                      ]
                    ),
                    child : Padding(
                      padding: const EdgeInsets.all(24), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700, 
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500, 
                            ),
                          ),
                          const SizedBox(height: 8), 
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
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: (){},
                              child: const Text("Lupa Password?", style: TextStyle(color: AppColors.primary)),
                            ),
                          ),

                          const SizedBox(height: 10), 

                          Center(
                            child: _isLoading 
                                ? const CircularProgressIndicator(color: AppColors.primary)
                                : CustomButton(
                                    text: "Login", 
                                    onPressed: _login,
                                  ),
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
