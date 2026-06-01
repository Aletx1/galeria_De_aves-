import 'package:flutter/material.dart';

import 'services/app_data_service.dart';
import 'views/comunidad.dart';
import 'views/galeria.dart';
import 'views/inicio.dart';
import 'views/perfil.dart';
import 'views/reportes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dataService = AppDataService();
  await dataService.init();
  runApp(AvesCLApp(dataService: dataService));
}

class AvesCLApp extends StatefulWidget {
  final AppDataService dataService;

  const AvesCLApp({super.key, required this.dataService});

  @override
  State<AvesCLApp> createState() => _AvesCLAppState();
}

class _AvesCLAppState extends State<AvesCLApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AvesCL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E8F63),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F2),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E8F63),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: MainNavigation(
        dataService: widget.dataService,
        toggleTheme: toggleTheme,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final AppDataService dataService;
  final VoidCallback toggleTheme;

  const MainNavigation({
    super.key,
    required this.dataService,
    required this.toggleTheme,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      InicioView(
        toggleTheme: widget.toggleTheme,
        dataService: widget.dataService,
      ),
      GaleriaView(dataService: widget.dataService),
      ComunidadView(dataService: widget.dataService),
      ReportesView(dataService: widget.dataService),
      PerfilView(
        dataService: widget.dataService,
        toggleTheme: widget.toggleTheme,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Galeria',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Comunidad',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
