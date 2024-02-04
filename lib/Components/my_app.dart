import 'package:flutter/material.dart';
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
    return MaterialApp(
      title: 'Quick Notes App',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: MyHomePage(
          title: 'Quick Notes App',
          changeTheme: _changeTheme,
          currentTheme: currentTheme),
    );
  }
}
