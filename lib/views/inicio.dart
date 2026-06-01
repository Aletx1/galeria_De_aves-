import 'dart:io';

import 'package:flutter/material.dart';

import '../models/bird_record.dart';
import '../services/app_data_service.dart';
import 'login.dart';

class InicioView extends StatelessWidget {
  final VoidCallback? toggleTheme;
  final AppDataService? dataService;

  const InicioView({super.key, this.toggleTheme, this.dataService});

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
                        Text(
                          'AvesCL',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E8F63),
                          ),
                        ),
                        Text(
                          'Bitacora fotografica de aves chilenas',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: toggleTheme,
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),
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
              const Text(
                'Ave del dia',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _DailyBirdCard(dataService: dataService),
              const SizedBox(height: 26),
              const Text(
                'Ultimos registros',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _RecentRecords(dataService: dataService),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyBirdCard extends StatelessWidget {
  final AppDataService? dataService;

  const _DailyBirdCard({required this.dataService});

  @override
  Widget build(BuildContext context) {
    if (dataService == null) {
      return const _DailyBirdSurface(
        name: 'Siete colores',
        scientificName: 'Tachuris rubrigastra',
        detail: 'Humedal - Certeza alta',
      );
    }

    return AnimatedBuilder(
      animation: dataService!,
      builder: (context, _) {
        final bird = dataService!.dailyBird;
        if (bird == null) {
          return const _DailyBirdSurface(
            name: 'Sin ave seleccionada',
            scientificName: 'Sube fotos en Galeria',
            detail: 'Tu ave del dia aparecera aqui',
          );
        }

        return _DailyBirdSurface(
          name: bird.commonName,
          scientificName: bird.scientificName,
          detail: '${bird.zone} - Certeza ${bird.certainty.toLowerCase()}',
          imagePath: bird.imagePath,
        );
      },
    );
  }
}

class _DailyBirdSurface extends StatelessWidget {
  final String name;
  final String scientificName;
  final String detail;
  final String? imagePath;

  const _DailyBirdSurface({
    required this.name,
    required this.scientificName,
    required this.detail,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9CCC65), Color(0xFF4E8F63)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.file(File(imagePath!), fit: BoxFit.cover)
          else
            Positioned(
              right: 24,
              top: 28,
              child: Icon(
                Icons.water,
                size: 96,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: hasImage ? 0.08 : 0),
                  Colors.black.withValues(alpha: hasImage ? 0.58 : 0),
                ],
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  scientificName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 10),
                Text(detail, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRecords extends StatelessWidget {
  final AppDataService? dataService;

  const _RecentRecords({required this.dataService});

  @override
  Widget build(BuildContext context) {
    if (dataService == null) {
      return const Column(
        children: [
          _RecentBirdTile(
            nombre: 'Loica',
            zona: 'Campo abierto',
            fecha: '15/04/2026',
            icono: Icons.grass,
          ),
          _RecentBirdTile(
            nombre: 'Chucao',
            zona: 'Bosque',
            fecha: '18/04/2026',
            icono: Icons.forest,
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation: dataService!,
      builder: (context, _) {
        final records = dataService!.birdRecords.take(3).toList();
        if (records.isEmpty) {
          return const Text('Aun no hay registros guardados.');
        }

        return Column(
          children: records.map((record) {
            return _RecentBirdTile(
              nombre: record.commonName,
              zona: record.zone,
              fecha: _formatShortDate(record.createdAt),
              icono: _iconForRecord(record),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _iconForRecord(BirdRecord record) {
    final zone = record.zone.toLowerCase();
    if (zone.contains('bosque')) return Icons.forest;
    if (zone.contains('cordillera')) return Icons.landscape;
    if (zone.contains('humedal')) return Icons.water;
    return record.isDraft ? Icons.edit_note : Icons.flutter_dash;
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
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE1F0D9),
          child: Icon(icono, color: const Color(0xFF4E8F63)),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$zona - $fecha'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

String _formatShortDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
