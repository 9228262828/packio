import 'package:flutter/material.dart';
import 'screens.dart';
import 'store.dart';
import 'ui.dart';

class PackioApp extends StatefulWidget {
  const PackioApp({super.key});

  @override
  State<PackioApp> createState() => _PackioAppState();
}

class _PackioAppState extends State<PackioApp> {
  final store = PackioStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PACKIO',
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: packioTheme(Brightness.light),
          darkTheme: packioTheme(Brightness.dark),
          home: SplashScreen(store: store),
        );
      },
    );
  }
}
