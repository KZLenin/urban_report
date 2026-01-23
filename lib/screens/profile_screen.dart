import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/config/supabase_config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = SupabaseConfig.client.auth.currentUser;

  // Función para cerrar sesión (Módulo 3.1)
  Future<void> _handleSignOut() async {
    await SupabaseConfig.client.auth.signOut();
    if (mounted) {
      // Al cerrar sesión, limpiamos el historial de navegación y volvemos al login
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.title),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar con iniciales o icono
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Módulo 3.1: Información del usuario
            _buildInfoCard(
              label: "Nombre Completo",
              value: user?.userMetadata?['full_name'] ?? "No disponible",
              icon: Icons.badge_outlined,
            ),
            _buildInfoCard(
              label: "Correo Electrónico",
              value: user?.email ?? "No disponible",
              icon: Icons.email_outlined,
            ),
            _buildInfoCard(
              label: "Cuenta creada el",
              value: user?.createdAt.split('T')[0] ?? "",
              icon: Icons.calendar_today_outlined,
            ),

            const SizedBox(height: 40),

            // Botón de Cierre de Sesión (Requisito Funcional)
            MaterialButton(
              minWidth: double.infinity,
              height: 55,
              onPressed: _handleSignOut,
              color: Colors.redAccent.withOpacity(0.1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: const BorderSide(color: Colors.redAccent),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text(
                    "Cerrar Sesión",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "UrbanReport v1.0.0",
              style: TextStyle(color: AppColors.body, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.body),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.title,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
