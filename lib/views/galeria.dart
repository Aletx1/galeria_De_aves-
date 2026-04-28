import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'inicio.dart';

class GaleriaView extends StatefulWidget {
  const GaleriaView({super.key});

  @override
  State<GaleriaView> createState() => _GaleriaViewState();
}

class _GaleriaViewState extends State<GaleriaView> {
  String busqueda = '';

  final ImagePicker picker = ImagePicker();

  final List<Map<String, dynamic>> aves = [];

  Future<void> subirFoto() async {
    final XFile? imagenSeleccionada = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagenSeleccionada == null) {
      return;
    }

    setState(() {
      aves.insert(0, {
        'nombre': 'Ave sin clasificar',
        'cientifico': 'Pendiente de identificar',
        'zona': 'Sin ubicación',
        'fecha': 'Registro nuevo',
        'certeza': 'Pendiente',
        'imagenFile': imagenSeleccionada.path,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto agregada a la galería.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avesFiltradas = aves.where((ave) {
      final texto = busqueda.toLowerCase();

      return ave['nombre'].toString().toLowerCase().contains(texto) ||
          ave['cientifico'].toString().toLowerCase().contains(texto) ||
          ave['zona'].toString().toLowerCase().contains(texto);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4E8F63),
        foregroundColor: Colors.white,
        onPressed: subirFoto,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Subir foto'),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const InicioView(),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mi galería',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF253528),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Tus registros personales aparecerán aquí cuando subas fotografías.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667066),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      busqueda = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar en galería...',
                    icon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: aves.isEmpty
                    ? const _GaleriaVacia()
                    : avesFiltradas.isEmpty
                        ? const Center(
                            child: Text('No se encontraron aves.'),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 90),
                            itemCount: avesFiltradas.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                            itemBuilder: (context, index) {
                              final ave = avesFiltradas[index];
                              return _AveCard(ave: ave);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaleriaVacia extends StatelessWidget {
  const _GaleriaVacia();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F0D9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 74,
                color: Color(0xFF4E8F63),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Tu galería está vacía',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF253528),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Sube tus primeras fotografías de aves para comenzar tu bitácora personal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF667066),
              ),
            ),

            const SizedBox(height: 22),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4E8F63),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final state =
                    context.findAncestorStateOfType<_GaleriaViewState>();
                state?.subirFoto();
              },
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Subir primera foto'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AveCard extends StatelessWidget {
  final Map<String, dynamic> ave;

  const _AveCard({
    required this.ave,
  });

  @override
  Widget build(BuildContext context) {
    final String? imagenFile = ave['imagenFile'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: imagenFile != null
                ? Image.file(
                    File(imagenFile),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    color: const Color(0xFFE1F0D9),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 56,
                      color: Color(0xFF4E8F63),
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ave['nombre'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  ave['zona'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF667066),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F0D9),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Certeza ${ave['certeza']}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4E8F63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}