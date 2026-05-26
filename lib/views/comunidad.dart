import 'package:flutter/material.dart';

class ComunidadView extends StatelessWidget {
  const ComunidadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comunidad AvesCL")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.deepOrange, size: 40),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Evento: Rapaces del Norte", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      Text("Sube tu mejor foto de un ave rapaz esta semana.", style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPost(context, "Felipe S.", "Hace 2 horas", "¡Increíble Cóndor visto en Farellones!"),
          _buildPost(context, "Troll_123", "Hace 5 horas", "Mira mi auto nuevo jaja"), // Ejemplo de post reportable
        ],
      ),
    );
  }

  Widget _buildPost(BuildContext context, String usuario, String tiempo, String descripcion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(usuario, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(tiempo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                // Botón para reportar publicación
                IconButton(
                  icon: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
                  tooltip: 'Reportar publicación',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Publicación enviada al Centro de Reportes")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(descripcion),
            const SizedBox(height: 10),
            Container(height: 150, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.photo))),
          ],
        ),
      ),
    );
  }
}