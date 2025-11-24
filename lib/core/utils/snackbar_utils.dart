import 'package:flutter/material.dart';

class AppSnackBars {
  static void show(BuildContext context, String message, {bool isError = false}) {
    // Hapus snackbar antrian sebelumnya agar responsif
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message, 
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating, // Agar melayang (tidak mentok bawah)
        margin: const EdgeInsets.all(20),    // Jarak dari pinggir layar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Sudut membulat
        ),
      ),
    );
  }
}