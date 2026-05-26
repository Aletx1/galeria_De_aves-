import 'package:flutter/material.dart';

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  bool filtroAutomaticoActivo = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Centro de Moderación")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Tarjeta de configuración de IA Moderadora
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SwitchListTile(
              title: const Text("Filtro IA de Obscenidades", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Usa Hugging Face API para censurar texto/imágenes inapropiadas automáticamente."),
              secondary: const Icon(Icons.security, color: Colors.green),
              value: filtroAutomaticoActivo,
              activeColor: const Color(0xFF4E8F63),
              onChanged: (bool value) {
                setState(() {
                  filtroAutomaticoActivo = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(value ? "Filtro IA Activado" : "Filtro IA Desactivado")),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text("Reportes Pendientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Lista de denuncias
          _buildReporteItem(
            usuarioReportado: "Troll_123",
            motivo: "Contenido irrelevante (No es un ave)",
            estado: "Pendiente revisión",
            colorEstado: Colors.orange,
          ),
          _buildReporteItem(
            usuarioReportado: "User_Anónimo",
            motivo: "Lenguaje ofensivo en descripción",
            estado: "Bloqueado por IA",
            colorEstado: Colors.red,
          ),
          _buildReporteItem(
            usuarioReportado: "Bot_Spam",
            motivo: "Spam / Publicidad",
            estado: "Resuelto (Usuario Baneado)",
            colorEstado: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildReporteItem({required String usuarioReportado, required String motivo, required String estado, required Color colorEstado}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.gavel, color: Colors.grey),
        title: Text("Reporte a: $usuarioReportado", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Motivo: $motivo"),
            const SizedBox(height: 4),
            Text("Estado: $estado", style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // Aquí iría la lógica para ver el detalle del reporte y banear/ignorar
          },
        ),
      ),
    );
  }
}