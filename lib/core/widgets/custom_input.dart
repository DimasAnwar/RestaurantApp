import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label; 
  final String hint;
  final bool isPassword;
  final double? width;
  final IconData? icon;
  final TextEditingController controller; 

  const CustomInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final inputWidth = width ?? MediaQuery.of(context).size.width * 0.8;
    
    return SizedBox(
      width: inputWidth,
      child: TextField(
        controller: controller, 
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), 
          
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          
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
