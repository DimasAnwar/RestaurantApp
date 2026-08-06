import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  bool _isLoading = false; 

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();

      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua kolom wajib diisi!')),
        );
        return;
      }

      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
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
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black), 
      ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8), 
              
              const Text(
                "Join FlavorFlow and elevate your dining experience.",
                style: TextStyle(color: Colors.grey), 
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
                isPassword: true, 
                controller: _passwordController,
              ),
              
              const SizedBox(height: 40), 
              
              Center(
                child: _isLoading 
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : CustomButton(
                        text: "Sign Up", 
                        onPressed: _signUp,
                      ),
              ),
              
              const SizedBox(height: 20), 
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an Account?"),
                  TextButton(
                    onPressed: (){
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
