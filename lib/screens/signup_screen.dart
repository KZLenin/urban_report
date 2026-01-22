import 'package:flutter/material.dart';
import 'package:urban_report/core/theme/app_colors.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.title),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "Crear Cuenta",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: AppColors.title,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Create una cuenta, es gratis",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.subtitle,
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  inputFile(label: "Nombre Completo"),
                  inputFile(label: "Correo"),
                  inputFile(label: "Contraseña", obscureText: true),
                  inputFile(label: "Confirmar contraseña", obscureText: true),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 3, left: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                    top: BorderSide(color: AppColors.border),
                    left: BorderSide(color: AppColors.border),
                    right: BorderSide(color: AppColors.border),
                  ),
                ),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () {},
                  color: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "Registrarse",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.buttonText,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "¿Ya tienes una cuenta?",
                    style: TextStyle(
                      color: AppColors.body,
                      fontSize: 15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      " Iniciar Sesión",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
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

Widget inputFile({label, obscureText = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.body,
        ),
      ),
      SizedBox(height: 5),
      TextField(
        obscureText: obscureText,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.border,
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
} 

