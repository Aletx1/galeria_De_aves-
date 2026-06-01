import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/bird_record.dart';
import '../services/app_data_service.dart';

class GaleriaView extends StatefulWidget {
  final AppDataService dataService;

  const GaleriaView({super.key, required this.dataService});

  @override
  State<GaleriaView> createState() => _GaleriaViewState();
}

class _GaleriaViewState extends State<GaleriaView> {
  String busqueda = '';
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    widget.dataService.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.dataService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> subirFoto() async {
    final XFile? imagenSeleccionada = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagenSeleccionada == null || !mounted) return;

    final result = await _showRegistroDialog();
    if (result == null) return;

    await widget.dataService.addBirdRecord(
      originalImagePath: imagenSeleccionada.path,
      commonName: result.commonName,
      scientificName: result.scientificName,
      zone: result.zone,
      certainty: result.certainty,
      notes: result.notes,
      status: result.status,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.status == BirdRecordStatus.draft
              ? 'Foto guardada como borrador.'
              : 'Foto guardada en tu galeria personal.',
        ),
      ),
    );
  }

  Future<_RegistroFormResult?> _showRegistroDialog() {
    final formKey = GlobalKey<FormState>();
    final commonNameController = TextEditingController(
      text: 'Ave sin clasificar',
    );
    final scientificNameController = TextEditingController();
    final zoneController = TextEditingController();
    final notesController = TextEditingController();
    String certainty = 'Pendiente';

    return showDialog<_RegistroFormResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo registro'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: commonNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre comun',
                          prefixIcon: Icon(Icons.flutter_dash),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: scientificNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre cientifico',
                          prefixIcon: Icon(Icons.science_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: zoneController,
                        decoration: const InputDecoration(
                          labelText: 'Zona o ubicacion',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: certainty,
                        decoration: const InputDecoration(
                          labelText: 'Certeza',
                          prefixIcon: Icon(Icons.verified_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Pendiente',
                            child: Text('Pendiente'),
                          ),
                          DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                          DropdownMenuItem(
                            value: 'Media',
                            child: Text('Media'),
                          ),
                          DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                        ],
                        onChanged: (value) {
                          setDialogState(
                            () => certainty = value ?? 'Pendiente',
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: notesController,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notas del avistamiento',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                    _RegistroFormResult(
                      commonName: commonNameController.text,
                      scientificName: scientificNameController.text,
                      zone: zoneController.text,
                      certainty: certainty,
                      notes: notesController.text,
                      status: BirdRecordStatus.draft,
                    ),
                  ),
                  child: const Text('Borrador'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4E8F63),
                  ),
                  onPressed: () => Navigator.pop(
                    context,
                    _RegistroFormResult(
                      commonName: commonNameController.text,
                      scientificName: scientificNameController.text,
                      zone: zoneController.text,
                      certainty: certainty,
                      notes: notesController.text,
                      status: BirdRecordStatus.published,
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final avesFiltradas = widget.dataService.birdRecords.where((ave) {
      final texto = busqueda.toLowerCase();
      return ave.commonName.toLowerCase().contains(texto) ||
          ave.zone.toLowerCase().contains(texto) ||
          ave.certainty.toLowerCase().contains(texto);
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
              const Text(
                'Mi galeria',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E8F63),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.dataService.birdRecords.length} registros guardados',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => busqueda = value),
                  decoration: const InputDecoration(
                    hintText: 'Buscar en galeria...',
                    icon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: avesFiltradas.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay registros para esta busqueda. Sube una foto para comenzar.',
                        ),
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
                          return _AveCard(
                            ave: ave,
                            onTap: () => _showBirdDetail(ave),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBirdDetail(BirdRecord ave) {
    final imagePath = ave.imagePath;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: imagePath != null && File(imagePath).existsSync()
                      ? Image.file(
                          File(imagePath),
                          width: double.infinity,
                          height: 280,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 220,
                          color: const Color(0xFFE1F0D9),
                          child: const Icon(
                            Icons.image_outlined,
                            size: 72,
                            color: Color(0xFF4E8F63),
                          ),
                        ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ave.commonName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ave.scientificName,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(ave: ave),
                  ],
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.place_outlined,
                  label: 'Lugar',
                  value: ave.zone,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha',
                  value: _formatLongDate(ave.createdAt),
                ),
                _DetailRow(
                  icon: Icons.verified_outlined,
                  label: 'Certeza',
                  value: ave.certainty,
                ),
                if (ave.notes.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Notas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(ave.notes),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    onPressed: () => _confirmDeleteBird(ave),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar de mi galeria'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteBird(BirdRecord ave) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar foto'),
          content: Text(
            'Se eliminara "${ave.commonName}" de tu galeria personal.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await widget.dataService.deleteBirdRecord(ave.id);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto eliminada de tu galeria.')),
    );
  }
}

class _AveCard extends StatelessWidget {
  final BirdRecord ave;
  final VoidCallback onTap;

  const _AveCard({required this.ave, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imagePath = ave.imagePath;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imagePath != null && File(imagePath).existsSync()
                  ? Image.file(
                      File(imagePath),
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
                    ave.commonName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    ave.zone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _StatusPill(ave: ave),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final BirdRecord ave;

  const _StatusPill({required this.ave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: ave.isDraft ? Colors.orange.shade100 : const Color(0xFFE1F0D9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        ave.isDraft ? 'Borrador' : ave.certainty,
        style: TextStyle(
          fontSize: 11,
          color: ave.isDraft ? Colors.deepOrange : const Color(0xFF4E8F63),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE1F0D9),
            child: Icon(icon, size: 19, color: const Color(0xFF4E8F63)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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

class _RegistroFormResult {
  final String commonName;
  final String scientificName;
  final String zone;
  final String certainty;
  final String notes;
  final BirdRecordStatus status;

  const _RegistroFormResult({
    required this.commonName,
    required this.scientificName,
    required this.zone,
    required this.certainty,
    required this.notes,
    required this.status,
  });
}

String _formatLongDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} $hour:$minute';
}
