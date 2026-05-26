import 'package:flutter/material.dart';
import 'views/inicio.dart';
import 'views/galeria.dart';
import 'views/comunidad.dart'; // Nuevo
import 'views/reportes.dart';  // Nuevo

void main() {
  runApp(const AvesCLApp());
}

class AvesCLApp extends StatefulWidget {
  const AvesCLApp({super.key});

  @override
  State<AvesCLApp> createState() => _AvesCLAppState();
}

class _AvesCLAppState extends State<AvesCLApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AvesCL',
      debugShowCheckedModeBanner: false,
      // Tu tema original claro
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E8F63),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F2),
      ),
      // Nuevo tema oscuro adaptado a tus colores
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E8F63),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: MainNavigation(toggleTheme: toggleTheme),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final VoidCallback toggleTheme;
  const MainNavigation({super.key, required this.toggleTheme});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    // Aquí conectamos todas tus vistas
    _views = [
      InicioView(toggleTheme: widget.toggleTheme),
      const GaleriaView(),
      const ComunidadView(),
      const ReportesView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library), label: 'Galería'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Comunidad'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Reportes'),
        ],
      ),
    );
  }
}