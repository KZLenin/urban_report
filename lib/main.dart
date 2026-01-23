import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_report/core/config/supabase_config.dart';
import 'core/theme/app_colors.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart'; // Asegúrate de importar tu pantalla principal de Tabs

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint("Error inicializando Supabase: $e");
  }

  // Verificamos si ya existe una sesión activa
  final session = Supabase.instance.client.auth.currentSession;

  runApp(MyApp(isLoggedIn: session != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Si está logueado va directo a MainScreen (Tabs), si no, a HomePage (Bienvenida)
      home: isLoggedIn ? const MainScreen() : const HomePage(),
    );
  }
}

// ... El resto de tu HomePage se mantiene igual

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // 🧾 Títulos
              Column(
                children: <Widget>[
                  Text(
                    "Bienvenido",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Reporta problemas de tu ciudad y contribuye a mejorar tu comunidad.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),

              // 🖼️ Imagen
              Image.asset(
                "assets/resources/welcome.png",
                height: MediaQuery.of(context).size.height / 3,
                fit: BoxFit.contain,
              ),

              // 🔘 Botones
              Column(
                children: <Widget>[
                  // Botón principal
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 56,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: AppColors.buttonText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón secundario
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 56,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    color: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "Registrarse",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: AppColors.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
