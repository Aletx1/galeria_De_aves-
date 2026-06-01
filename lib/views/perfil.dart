import 'package:flutter/material.dart';

import '../services/app_data_service.dart';
import 'login.dart';

class PerfilView extends StatefulWidget {
  final AppDataService dataService;
  final VoidCallback toggleTheme;

  const PerfilView({
    super.key,
    required this.dataService,
    required this.toggleTheme,
  });

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
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

  @override
  Widget build(BuildContext context) {
    final records = widget.dataService.birdRecords;
    final drafts = records.where((record) => record.isDraft).length;
    final published = records.length - drafts;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4E8F63),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Color(0xFFE1F0D9),
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF4E8F63),
                      size: 38,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuario AvesCL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          'Galeria personal de aves chilenas',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    label: 'Fotos',
                    value: '${records.length}',
                    icon: Icons.photo_library_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProfileStat(
                    label: 'Guardadas',
                    value: '$published',
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    label: 'Borradores',
                    value: '$drafts',
                    icon: Icons.edit_note,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProfileStat(
                    label: 'Eventos',
                    value: '${widget.dataService.joinedEventsCount}',
                    icon: Icons.emoji_events_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ProfileAction(
              icon: Icons.dark_mode_outlined,
              title: 'Cambiar tema',
              subtitle: 'Alternar entre modo claro y oscuro',
              onTap: widget.toggleTheme,
            ),
            _ProfileAction(
              icon: Icons.report_outlined,
              title: 'Reportes creados',
              subtitle:
                  '${widget.dataService.reports.length} reportes en la app',
              onTap: () {},
            ),
            _ProfileAction(
              icon: Icons.logout,
              title: 'Cerrar sesion',
              subtitle: 'Volver a la pantalla de ingreso',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4E8F63)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE1F0D9),
          child: Icon(icon, color: const Color(0xFF4E8F63)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
