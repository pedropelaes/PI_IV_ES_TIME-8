import 'package:flutter/material.dart';

class TextFieldDesign extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final BuildContext context;
  final bool isPassword;
  final bool enabled;

  const TextFieldDesign({
    required this.controller,
    required this.hintText,
    required this.context,
    this.isPassword = false,
    this.enabled = true,
  });

  @override
  State<TextFieldDesign> createState() => _TextFieldDesignState();
}

class _TextFieldDesignState extends State<TextFieldDesign> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 40),
      child: TextField(
        enabled: widget.enabled,
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.surface,
          ),
          filled: true,
          fillColor: theme.colorScheme.onSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: theme.colorScheme.surface,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.surface,
        ),
      ),
    );
  }
}