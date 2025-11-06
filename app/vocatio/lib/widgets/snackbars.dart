import 'package:flutter/material.dart';

  void showErrorSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSuccessSnackBar(String message,  BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showTopSnackBar(String message, BuildContext context, {bool isError = true}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60.0,
        left: 16.0,
        right: 16.0,
        child: Material(
          elevation: 8.0,
          borderRadius: BorderRadius.circular(8),
          color: isError ? Colors.red.shade800 : Colors.green.shade800,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }