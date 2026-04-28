import 'package:flutter/material.dart';
import 'galeria.dart';
import 'login.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const GaleriaView(),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: 'Galería',
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AvesCL',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF253528),
                          ),
                        ),
                        Text(
                          'Bitácora fotográfica de aves chilenas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF667066),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginView(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar especie, zona o fecha...',
                    icon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Ave del día',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF253528),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF9CCC65),
                      Color(0xFF4E8F63),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 24,
                      top: 28,
                      child: Icon(
                        Icons.water,
                        size: 96,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                    const Positioned(
                      left: 22,
                      right: 22,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Siete colores',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tachuris rubrigastra',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Humedal · Certeza alta',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                'Accesos rápidos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF253528),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_a_photo_outlined,
                      title: 'Nuevo registro',
                      subtitle: 'Agregar ave',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Nuevo Registro será agregado en la siguiente etapa.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.psychology_outlined,
                      title: 'IA Recon',
                      subtitle: 'Verificar especie',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'IA Recon funcionará como apoyo para verificar especies.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              const Text(
                'Últimos registros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF253528),
                ),
              ),

              const SizedBox(height: 12),

              const _RecentBirdTile(
                nombre: 'Loica',
                zona: 'Campo abierto',
                fecha: '15/04/2026',
                icono: Icons.grass,
              ),
              const _RecentBirdTile(
                nombre: 'Chucao',
                zona: 'Bosque',
                fecha: '18/04/2026',
                icono: Icons.forest,
              ),
              const _RecentBirdTile(
                nombre: 'Cóndor',
                zona: 'Cordillera',
                fecha: '20/04/2026',
                icono: Icons.landscape,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 30,
                color: const Color(0xFF4E8F63),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF667066),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentBirdTile extends StatelessWidget {
  final String nombre;
  final String zona;
  final String fecha;
  final IconData icono;

  const _RecentBirdTile({
    required this.nombre,
    required this.zona,
    required this.fecha,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE1F0D9),
          child: Icon(
            icono,
            color: const Color(0xFF4E8F63),
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$zona · $fecha'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}