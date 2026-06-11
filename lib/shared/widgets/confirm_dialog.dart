import 'package:flutter/material.dart';

class ConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = "Confirm",
    String cancelText = "Cancel",
    IconData icon = Icons.help_outline,
  }) async {
    final size = MediaQuery.of(context).size;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.06),
          ),
          contentPadding: EdgeInsets.all(size.width * 0.05),
          content: SizedBox(
            width: size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: size.width * 0.08,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  child: Icon(
                    icon,
                    size: size.width * 0.08,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.width * 0.038,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: size.height * 0.025),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: size.width * 0.03),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text(
                          confirmText,
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }
}