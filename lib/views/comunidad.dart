import 'dart:io';

import 'package:flutter/material.dart';

import '../models/bird_record.dart';
import '../models/community_event.dart';
import '../services/app_data_service.dart';

class ComunidadView extends StatefulWidget {
  final AppDataService dataService;

  const ComunidadView({super.key, required this.dataService});

  @override
  State<ComunidadView> createState() => _ComunidadViewState();
}

class _ComunidadViewState extends State<ComunidadView> {
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

  Future<void> _createEvent() async {
    final result = await _showEventDialog();
    if (result == null) return;

    await widget.dataService.addCommunityEvent(
      title: result.title,
      description: result.description,
      birdFocus: result.birdFocus,
      durationDays: result.durationDays,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento creado en Comunidad.')),
    );
  }

  Future<void> _joinEvent(CommunityEvent event) async {
    if (event.currentUserParticipated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya participaste en este evento.')),
      );
      return;
    }

    final selectedBird = await _showBirdPicker(event);
    if (selectedBird == null) return;

    final joined = await widget.dataService.joinEvent(
      event.id,
      selectedBird.id,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          joined
              ? 'Enviaste "${selectedBird.commonName}" a "${event.title}".'
              : 'Ya participaste en este evento.',
        ),
      ),
    );
  }

  Future<void> _likeEvent(CommunityEvent event) async {
    final liked = await widget.dataService.likeEvent(event.id);
    if (!mounted || liked) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ya diste like a este evento.')),
    );
  }

  Future<void> _reportEvent(CommunityEvent event) async {
    final result = await _showReportDialog(event);
    if (result == null) return;

    await widget.dataService.createEventReport(
      event: event,
      reason: result.reason,
      detail: result.detail,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte enviado al centro de moderacion.')),
    );
  }

  Future<_EventFormResult?> _showEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final birdFocusController = TextEditingController();
    int durationDays = 7;

    return showDialog<_EventFormResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear evento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del evento',
                        prefixIcon: Icon(Icons.emoji_events_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: birdFocusController,
                      decoration: const InputDecoration(
                        labelText: 'Tema o ave protagonista',
                        prefixIcon: Icon(Icons.flutter_dash),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripcion',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(child: Text('Duracion')),
                        DropdownButton<int>(
                          value: durationDays,
                          items: const [
                            DropdownMenuItem(value: 3, child: Text('3 dias')),
                            DropdownMenuItem(value: 7, child: Text('7 dias')),
                            DropdownMenuItem(value: 14, child: Text('14 dias')),
                          ],
                          onChanged: (value) {
                            setDialogState(
                              () => durationDays = value ?? durationDays,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4E8F63),
                  ),
                  onPressed: () => Navigator.pop(
                    context,
                    _EventFormResult(
                      title: titleController.text,
                      description: descriptionController.text,
                      birdFocus: birdFocusController.text,
                      durationDays: durationDays,
                    ),
                  ),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<_ReportFormResult?> _showReportDialog(CommunityEvent event) {
    final detailController = TextEditingController();
    String reason = 'Informacion incorrecta';

    return showDialog<_ReportFormResult>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Reportar evento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E8F63),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: reason,
                    decoration: const InputDecoration(
                      labelText: 'Motivo',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Informacion incorrecta',
                        child: Text('Informacion incorrecta'),
                      ),
                      DropdownMenuItem(
                        value: 'Spam / publicidad',
                        child: Text('Spam / publicidad'),
                      ),
                      DropdownMenuItem(
                        value: 'Contenido ofensivo',
                        child: Text('Contenido ofensivo'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() => reason = value ?? reason);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Detalle opcional',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4E8F63),
                  ),
                  onPressed: () => Navigator.pop(
                    context,
                    _ReportFormResult(
                      reason: reason,
                      detail: detailController.text,
                    ),
                  ),
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<BirdRecord?> _showBirdPicker(CommunityEvent event) {
    final birds = widget.dataService.birdRecords;

    return showModalBottomSheet<BirdRecord>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        if (birds.isEmpty) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Primero sube una foto en Galeria para participar en eventos.',
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participar en "${event.title}"',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Elige una foto de tu galeria personal para este evento.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 360,
                  child: ListView.builder(
                    itemCount: birds.length,
                    itemBuilder: (context, index) {
                      final bird = birds[index];
                      return _BirdPickerTile(
                        bird: bird,
                        onTap: () => Navigator.pop(context, bird),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.dataService.communityEvents;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4E8F63),
        foregroundColor: Colors.white,
        onPressed: _createEvent,
        icon: const Icon(Icons.add),
        label: const Text('Evento'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Comunidad',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E8F63),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Eventos y competencias fotograficas',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.deepOrange,
                      size: 38,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Competencias por likes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Crea desafios tematicos para futuras fotos destacadas.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: events.isEmpty
                    ? const Center(child: Text('No hay eventos activos.'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _EventCard(
                            event: event,
                            onLike: () => _likeEvent(event),
                            onJoin: () => _joinEvent(event),
                            onReport: () => _reportEvent(event),
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
}

class _EventCard extends StatelessWidget {
  final CommunityEvent event;
  final VoidCallback onLike;
  final VoidCallback onJoin;
  final VoidCallback onReport;

  const _EventCard({
    required this.event,
    required this.onLike,
    required this.onJoin,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = event.endsAt.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE1F0D9),
                  child: Icon(Icons.emoji_events, color: Color(0xFF4E8F63)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        event.birdFocus,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.report_problem_outlined,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Reportar evento',
                  onPressed: onReport,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(event.description),
            const SizedBox(height: 14),
            Row(
              children: [
                _InfoPill(
                  icon: Icons.favorite_border,
                  label: '${event.likes} likes',
                ),
                const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.groups_outlined,
                  label: '${event.participants} participantes',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoPill(
              icon: Icons.timer_outlined,
              label: daysLeft >= 0 ? 'Quedan $daysLeft dias' : 'Finalizado',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4E8F63),
                    ),
                    onPressed: event.currentUserParticipated ? null : onJoin,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      event.currentUserParticipated
                          ? 'Participando'
                          : 'Participar',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: event.likedByCurrentUser ? null : onLike,
                  icon: Icon(
                    event.likedByCurrentUser
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  tooltip: event.likedByCurrentUser ? 'Like dado' : 'Dar like',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F0D9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF4E8F63)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4E8F63),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BirdPickerTile extends StatelessWidget {
  final BirdRecord bird;
  final VoidCallback onTap;

  const _BirdPickerTile({required this.bird, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imagePath = bird.imagePath;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imagePath != null && File(imagePath).existsSync()
              ? Image.file(
                  File(imagePath),
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 52,
                  height: 52,
                  color: const Color(0xFFE1F0D9),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF4E8F63),
                  ),
                ),
        ),
        title: Text(
          bird.commonName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(bird.zone),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EventFormResult {
  final String title;
  final String description;
  final String birdFocus;
  final int durationDays;

  const _EventFormResult({
    required this.title,
    required this.description,
    required this.birdFocus,
    required this.durationDays,
  });
}

class _ReportFormResult {
  final String reason;
  final String detail;

  const _ReportFormResult({required this.reason, required this.detail});
}
