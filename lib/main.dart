import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

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
      title: 'Flutter Demo',
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: MyHomePage(
          title: 'Quick Notes App',
          changeTheme: _changeTheme,
          currentTheme: currentTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Function(ThemeMode) changeTheme;
  final ThemeMode currentTheme;

  const MyHomePage(
      {Key? key,
      required this.title,
      required this.changeTheme,
      required this.currentTheme})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      const Text('Notes Page'),
      SettingsPage(
          changeTheme: widget.changeTheme, currentTheme: widget.currentTheme),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          textAlign: TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 8.0,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Function(ThemeMode) changeTheme;
  final ThemeMode currentTheme;

  const SettingsPage(
      {super.key, required this.changeTheme, required this.currentTheme});

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
            showAboutDialog(
              context: context,
              applicationName: 'Quick Notes App',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.notes, color: Colors.blue),
              applicationLegalese: '© 2021 Quick Notes App',
            );
          },
        ),
      ],
    );
  }
}
