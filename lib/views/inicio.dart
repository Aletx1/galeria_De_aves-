import 'package:flutter/material.dart';
import 'login.dart';

class InicioView extends StatelessWidget {
  final VoidCallback? toggleTheme; // Recibimos la función para cambiar el tema
  const InicioView({super.key, this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
                        Text('AvesCL', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF4E8F63))),
                        Text('Bitácora fotográfica de aves chilenas', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                  // NUEVO: Botón de Tema
                  IconButton(
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: toggleTheme,
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),
              
              // TU BUSCADOR ORIGINAL
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
              const Text('Ave del día', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // TU TARJETA DEL AVE DEL DÍA (Intacta)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9CCC65), Color(0xFF4E8F63)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 24, top: 28,
                      child: Icon(Icons.water, size: 96, color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    const Positioned(
                      left: 22, right: 22, bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Siete colores', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          Text('Tachuris rubrigastra', style: TextStyle(color: Colors.white, fontSize: 15, fontStyle: FontStyle.italic)),
                          SizedBox(height: 10),
                          Text('Humedal · Certeza alta', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Text('Últimos registros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const _RecentBirdTile(nombre: 'Loica', zona: 'Campo abierto', fecha: '15/04/2026', icono: Icons.grass),
              const _RecentBirdTile(nombre: 'Chucao', zona: 'Bosque', fecha: '18/04/2026', icono: Icons.forest),
              const _RecentBirdTile(nombre: 'Cóndor', zona: 'Cordillera', fecha: '20/04/2026', icono: Icons.landscape),
            ],
          ),
        ),
      ),
    );
  }
}

// Tus widgets personalizados que ya tenías abajo (Tiles)
class _RecentBirdTile extends StatelessWidget {
  final String nombre;
  final String zona;
  final String fecha;
  final IconData icono;

  const _RecentBirdTile({required this.nombre, required this.zona, required this.fecha, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFFE1F0D9), child: Icon(icono, color: const Color(0xFF4E8F63))),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$zona · $fecha'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}