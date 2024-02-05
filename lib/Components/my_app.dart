import 'package:flutter/material.dart';
import 'package:quick_notes_app/Util/note_class.dart';
import 'my_home_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  ThemeMode get currentTheme => _themeMode;

  @override
  Widget build(BuildContext context) {
    _themeMode = ThemeUtils.useLightMode(_themeMode, context)
        ? ThemeMode.light
        : ThemeMode.dark;
    return MaterialApp(
      title: 'Quick Notes App',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
          colorSchemeSeed: Colors.lightBlue,
          useMaterial3: true,
          brightness: Brightness.light),
      darkTheme: ThemeData(
          colorSchemeSeed: Colors.lightBlue,
          useMaterial3: true,
          brightness: Brightness.dark),
      home: MyHomePage(
        title: 'Quick Notes App',
        changeTheme: _changeTheme,
        currentTheme: currentTheme,
      ),
    );
  }
}
