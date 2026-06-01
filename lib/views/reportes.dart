import 'package:flutter/material.dart';

import '../models/moderation_report.dart';
import '../services/app_data_service.dart';

class ReportesView extends StatefulWidget {
  final AppDataService dataService;

  const ReportesView({super.key, required this.dataService});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  ReportStatus? _statusFilter;

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

  Future<void> _openManualReportForm() async {
    final result = await _showManualReportDialog();
    if (result == null) return;

    await widget.dataService.createManualReport(
      reportedUser: result.user,
      reason: result.reason,
      detail: result.detail,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reporte manual creado.')));
  }

  Future<_ManualReportResult?> _showManualReportDialog() {
    final userController = TextEditingController();
    final reasonController = TextEditingController();
    final detailController = TextEditingController();

    return showDialog<_ManualReportResult>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo reporte'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: userController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario reportado',
                    prefixIcon: Icon(Icons.person_search_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: detailController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Detalle',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
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
                _ManualReportResult(
                  user: userController.text,
                  reason: reasonController.text,
                  detail: detailController.text,
                ),
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reviewReport(ModerationReport report) async {
    final action = await showModalBottomSheet<ReportStatus>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reporte a ${report.reportedUser}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Motivo: ${report.reason}'),
                if (report.detail.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(report.detail),
                ],
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.redAccent),
                  title: const Text('Bloquear publicacion'),
                  onTap: () => Navigator.pop(context, ReportStatus.blocked),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF4E8F63),
                  ),
                  title: const Text('Marcar como resuelto'),
                  onTap: () => Navigator.pop(context, ReportStatus.resolved),
                ),
                ListTile(
                  leading: const Icon(Icons.undo_outlined),
                  title: const Text('Descartar reporte'),
                  onTap: () => Navigator.pop(context, ReportStatus.dismissed),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == null) return;
    await widget.dataService.updateReportStatus(report.id, action);
  }

  @override
  Widget build(BuildContext context) {
    final reports = widget.dataService.reports;
    final filteredReports = _statusFilter == null
        ? reports
        : reports.where((report) => report.status == _statusFilter).toList();
    final pendingCount = reports
        .where((report) => report.status == ReportStatus.pending)
        .length;
    final blockedCount = reports
        .where((report) => report.status == ReportStatus.blocked)
        .length;
    final resolvedCount = reports
        .where((report) => report.status == ReportStatus.resolved)
        .length;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4E8F63),
        foregroundColor: Colors.white,
        onPressed: _openManualReportForm,
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('Nuevo'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reportes',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E8F63),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Filtro automatico',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Prepara el flujo para moderacion automatica antes de Firebase.',
                  ),
                  secondary: const Icon(
                    Icons.security,
                    color: Color(0xFF4E8F63),
                  ),
                  value: widget.dataService.moderationFilterEnabled,
                  activeThumbColor: const Color(0xFF4E8F63),
                  onChanged: widget.dataService.setModerationFilterEnabled,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Pendientes',
                      value: '$pendingCount',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Bloqueados',
                      value: '$blockedCount',
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Resueltos',
                      value: '$resolvedCount',
                      color: const Color(0xFF4E8F63),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todos',
                      selected: _statusFilter == null,
                      onTap: () => setState(() => _statusFilter = null),
                    ),
                    _FilterChip(
                      label: 'Pendientes',
                      selected: _statusFilter == ReportStatus.pending,
                      onTap: () =>
                          setState(() => _statusFilter = ReportStatus.pending),
                    ),
                    _FilterChip(
                      label: 'Bloqueados',
                      selected: _statusFilter == ReportStatus.blocked,
                      onTap: () =>
                          setState(() => _statusFilter = ReportStatus.blocked),
                    ),
                    _FilterChip(
                      label: 'Resueltos',
                      selected: _statusFilter == ReportStatus.resolved,
                      onTap: () =>
                          setState(() => _statusFilter = ReportStatus.resolved),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredReports.isEmpty
                    ? const Center(
                        child: Text('No hay reportes en este filtro.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = filteredReports[index];
                          return _ReportCard(
                            report: report,
                            onReview: () => _reviewReport(report),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: const Color(0xFFE1F0D9),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ModerationReport report;
  final VoidCallback onReview;

  const _ReportCard({required this.report, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(report.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(Icons.gavel_outlined, color: color),
        ),
        title: Text(
          'Reporte a: ${report.reportedUser}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Motivo: ${report.reason}'),
              const SizedBox(height: 4),
              Text(
                'Estado: ${_statusLabel(report.status)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (report.automaticFlag)
                const Text(
                  'Marcado por filtro automatico',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: onReview,
        ),
      ),
    );
  }
}

class _ManualReportResult {
  final String user;
  final String reason;
  final String detail;

  const _ManualReportResult({
    required this.user,
    required this.reason,
    required this.detail,
  });
}

Color _statusColor(ReportStatus status) {
  return switch (status) {
    ReportStatus.pending => Colors.orange,
    ReportStatus.blocked => Colors.redAccent,
    ReportStatus.resolved => const Color(0xFF4E8F63),
    ReportStatus.dismissed => Colors.grey,
  };
}

String _statusLabel(ReportStatus status) {
  return switch (status) {
    ReportStatus.pending => 'Pendiente revision',
    ReportStatus.blocked => 'Bloqueado',
    ReportStatus.resolved => 'Resuelto',
    ReportStatus.dismissed => 'Descartado',
  };
}
