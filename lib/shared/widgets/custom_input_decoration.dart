import 'package:flutter/material.dart';

class CustomInputDecoration {
  static InputDecoration build({
    required String hint,
    required IconData icon,
    required ThemeData theme,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7)),
      hintText: hint,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
      filled: true,
      fillColor: theme.scaffoldBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }
}
