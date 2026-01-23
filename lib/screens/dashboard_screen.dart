import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/config/supabase_config.dart';
import 'report_detail_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // El Stream permite escuchar cambios en tiempo real en la base de datos
  // Se define fuera del build para evitar que se reinicie innecesariamente
  late Stream<List<Map<String, dynamic>>> _reportsStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _reportsStream = SupabaseConfig.client
        .from('reportes')
        .stream(primaryKey: ['id'])
        .eq('usuario_id', SupabaseConfig.client.auth.currentUser!.id)
        .order('created_at', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Mis Reportes",
          style: TextStyle(color: AppColors.title, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _reportsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // El EmptyState también debe permitir recargar deslizando
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _initStream();
                });
              },
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: _buildEmptyState(),
                  ),
                ],
              ),
            );
          }

          final reportes = snapshot.data!;

          // --- AGREGADO: RefreshIndicator ---
          return RefreshIndicator(
            onRefresh: () async {
              // Forzamos el reinicio del stream
              setState(() {
                _initStream();
              });
              // Simulamos una pequeña espera para la animación
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              // physics asegura que siempre se pueda deslizar, aunque haya pocos elementos
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: reportes.length,
              itemBuilder: (context, index) {
                final reporte = reportes[index];
                return _buildReportCard(context, reporte);
              },
            ),
          );
        },
      ),
    );
  }

  // Widget para cuando no hay reportes
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 80,
            color: AppColors.subtitle.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            "Aún no tienes reportes",
            style: TextStyle(
              fontSize: 18,
              color: AppColors.subtitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const Text("Usa el mapa para crear uno nuevo."),
        ],
      ),
    );
  }

  // Widget de la tarjeta (Card) de cada reporte
  Widget _buildReportCard(BuildContext context, Map<String, dynamic> reporte) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:
              reporte['foto_url'] != null
                  ? Image.network(
                    reporte['foto_url'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    color: Colors.grey[300],
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.image_not_supported),
                  ),
        ),
        title: Text(
          reporte['titulo'] ?? "Sin título",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.title,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reporte['categoria'].toString().toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            _buildStatusBadge(reporte['estado']),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailPage(reporte: reporte),
            ),
          );
        },
      ),
    );
  }

  // Badge para el estado (pendiente, en proceso, resuelto)
  Widget _buildStatusBadge(String estado) {
    Color color;
    switch (estado) {
      case 'resuelto':
        color = Colors.green;
        break;
      case 'en_proceso':
        color = Colors.orange;
        break;
      default:
        color = Colors.redAccent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        estado.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
