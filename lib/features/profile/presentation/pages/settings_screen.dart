import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/theme_controller.dart';
import '../../../../shared/widgets/custom_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// NOTIFICATIONS
          // SwitchListTile(
          //   activeColor: theme.colorScheme.primary,
          //   title: const Text("Notifications"),
          //   subtitle: const Text("Enable or disable notifications"),
          //   value: notifications,
          //   onChanged: (value) {
          //     setState(() {
          //       notifications = value;
          //     });
          //   },
          // ),

          /// DARK MODE
          SwitchListTile(
            activeColor: theme.colorScheme.primary,
            title: const Text("Dark Mode"),
            subtitle: const Text("Switch app theme"),
            value: context.watch<ThemeController>().isDark,
            onChanged: (value) {
              context.read<ThemeController>().toggleTheme(value);
            },
          ),

          const Divider(),

          /// ABOUT
          ListTile(
            leading: Icon(Icons.info, color: theme.colorScheme.primary),
            title: const Text("About App"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Veemadeforyou",
                applicationVersion: "1.0.0",
                applicationLegalese: "Made with love",
              );
            },
          ),

          /// HELP
          ListTile(
            leading: Icon(Icons.help, color: theme.colorScheme.primary),
            title: const Text("Help & Support"),
            onTap: () async {
              await CustomDialog.show(
                context: context,
                title: "Help",
                message: "Help Coming Soon.",
                buttonText: "Okay",
                icon: Icons.help,
              );
            },
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
