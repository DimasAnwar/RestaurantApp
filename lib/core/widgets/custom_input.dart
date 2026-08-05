import 'package:flutter/material.dart'; // Typo import udah ilang

class CustomInput extends StatelessWidget {
  // text bisa lu ganti namanya jadi label biar lebih jelas
  final String label; 
  final String hint;
  final bool isPassword;
  final double? width;
  
  // INI WAJIB ADA BUAT NANGKEP KETIKAN USER
  final TextEditingController controller; 

  const CustomInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller, // Controller jadi wajib diisi
    this.isPassword = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputWidth = width ?? MediaQuery.of(context).size.width * 0.85;
    
    return SizedBox(
      width: inputWidth,
      // height: 55 dihapus, biarkan TextField bernapas
      child: TextField(
        controller: controller, // Pasang controller-nya di sini
        obscureText: isPassword, // Kalau isPassword true, teks jadi bulet-bulet
        decoration: InputDecoration(
          labelText: label, // Nampilin judul input
          hintText: hint,
          
          // Bikin input kelihatan tinggi pakai padding dalam, bukan SizedBox
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), 
          
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          
          // Opsional: Bikin warna border pas lagi diklik (fokus)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor, 
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}