import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final Function(ThemeMode) changeTheme;
  final ThemeMode currentTheme;

  const SettingsPage(
      {Key? key, required this.changeTheme, required this.currentTheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        SwitchListTile(
          title: Text(
              currentTheme == ThemeMode.dark ? 'Light Theme' : 'Dark Theme'),
          value: currentTheme == ThemeMode.dark,
          onChanged: (bool value) {
            changeTheme(value ? ThemeMode.dark : ThemeMode.light);
          },
        ),
        ListTile(
          title: const Text('About'),
          onTap: () {
            showGeneralDialog(
                context: context,
                pageBuilder: (context, a, b) {
                  return const AboutDialog(
                      applicationIcon: Icon(Icons.notes),
                      applicationName: 'Quick Notes App',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2021 Quick Notes App');
                });
          },
        ),
      ],
    );
  }
}
