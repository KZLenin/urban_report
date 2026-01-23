import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/config/supabase_config.dart';

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> reporte;

  const ReportDetailPage({super.key, required this.reporte});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.reporte['titulo']);
    _descripcionController = TextEditingController(
      text: widget.reporte['descripcion'],
    );
  }

  // --- FUNCIÓN PARA ACTUALIZAR (U de CRUD) ---
  Future<void> _updateReport() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseConfig.client
          .from('reportes')
          .update({
            'titulo': _tituloController.text.trim(),
            'descripcion': _descripcionController.text.trim(),
          })
          .eq('id', widget.reporte['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reporte actualizado correctamente")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al actualizar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- FUNCIÓN PARA ELIMINAR (D de CRUD) ---
  Future<void> _deleteReport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("¿Eliminar reporte?"),
            content: const Text("Esta acción no se puede deshacer."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await SupabaseConfig.client
            .from('reportes')
            .delete()
            .eq('id', widget.reporte['id']);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Reporte eliminado")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalle del Reporte",
          style: TextStyle(color: AppColors.title),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _deleteReport,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visualización de la Imagen (Módulo 3.3)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child:
                  widget.reporte['foto_url'] != null
                      ? Image.network(
                        widget.reporte['foto_url'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
            ),
            const SizedBox(height: 20),

            // Campos de edición
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Información no editable
            Text(
              "Categoría: ${widget.reporte['categoria']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Estado: ${widget.reporte['estado']}"),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Guardar Cambios",
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
