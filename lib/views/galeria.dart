import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

    if (imagenSeleccionada == null) return;

    // NUEVO: Cuadro de diálogo para Borrador vs Publicar
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guardar Registro'),
          content: const Text('¿Deseas publicar este avistamiento o guardarlo como borrador para completarlo luego?'),
          actions: [
            TextButton(
              onPressed: () {
                _agregarALaLista(imagenSeleccionada.path, esBorrador: true);
                Navigator.pop(context);
              },
              child: const Text('Guardar Borrador', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4E8F63)),
              onPressed: () {
                _agregarALaLista(imagenSeleccionada.path, esBorrador: false);
                Navigator.pop(context);
              },
              child: const Text('Publicar Registro'),
            ),
          ],
        );
      },
    );
  }

  void _agregarALaLista(String path, {required bool esBorrador}) {
    setState(() {
      aves.insert(0, {
        'nombre': esBorrador ? 'Borrador sin nombre' : 'Ave sin clasificar',
        'cientifico': 'Pendiente de identificar',
        'zona': 'Sin ubicación',
        'fecha': 'Registro nuevo',
        'certeza': esBorrador ? 'Borrador' : 'Pendiente',
        'imagenFile': path,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(esBorrador ? 'Guardado en borradores.' : 'Foto agregada a la galería.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final avesFiltradas = aves.where((ave) {
      final texto = busqueda.toLowerCase();
      return ave['nombre'].toString().toLowerCase().contains(texto) ||
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mi galería', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF4E8F63))),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18)),
                child: TextField(
                  onChanged: (value) => setState(() => busqueda = value),
                  decoration: const InputDecoration(hintText: 'Buscar en galería...', icon: Icon(Icons.search), border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: aves.isEmpty
                    ? const Center(child: Text("Galería vacía. ¡Presiona 'Subir foto' para comenzar!"))
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: avesFiltradas.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.72,
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

// Tu _AveCard original se mantiene
class _AveCard extends StatelessWidget {
  final Map<String, dynamic> ave;
  const _AveCard({required this.ave});

  @override
  Widget build(BuildContext context) {
    final String? imagenFile = ave['imagenFile'];
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: imagenFile != null
                ? Image.file(File(imagenFile), width: double.infinity, fit: BoxFit.cover)
                : Container(width: double.infinity, color: const Color(0xFFE1F0D9), child: const Icon(Icons.image_outlined, size: 56, color: Color(0xFF4E8F63))),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ave['nombre'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(ave['zona'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(color: ave['certeza'] == 'Borrador' ? Colors.orange.shade100 : const Color(0xFFE1F0D9), borderRadius: BorderRadius.circular(99)),
                  child: Text(ave['certeza'], style: TextStyle(fontSize: 11, color: ave['certeza'] == 'Borrador' ? Colors.deepOrange : const Color(0xFF4E8F63), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}