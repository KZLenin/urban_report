import 'dart:io';
import 'package:flutter/foundation.dart'; // Importante para kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme/app_colors.dart';
import '../core/config/supabase_config.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  String _categoriaSeleccionada = 'bache';
  LatLng? _ubicacionReal; 
  bool _ubicacionObtenida = false;
  
  // Variables para imagen (Soporte Web y Móvil)
  File? _imageFile;
  Uint8List? _webImage;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _capturarUbicacionActual();
  }

  Future<void> _capturarUbicacionActual() async {
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        _ubicacionReal = LatLng(position.latitude, position.longitude);
        _ubicacionObtenida = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener ubicación: $e"))
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = File(pickedFile.path); 
        });
      } else {
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  Future<void> _saveReport() async {
    // Validamos que haya imagen (ya sea en bytes o archivo)
    if (!_formKey.currentState!.validate() || (_imageFile == null && _webImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa el formulario y toma una foto")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = SupabaseConfig.client.auth.currentUser;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = 'reports/${user!.id}/$fileName';
      
      // Módulo 3.3: Subida diferenciada Web/Móvil
      if (kIsWeb) {
        await SupabaseConfig.client.storage
            .from('fotos_reportes')
            .uploadBinary(imagePath, _webImage!);
      } else {
        await SupabaseConfig.client.storage
            .from('fotos_reportes')
            .upload(imagePath, _imageFile!);
      }

      final imageUrl = SupabaseConfig.client.storage
          .from('fotos_reportes')
          .getPublicUrl(imagePath);

      // Módulo 3.2: Guardar con la ubicación real obtenida
      await SupabaseConfig.client.from('reportes').insert({
        'usuario_id': user.id,
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'categoria': _categoriaSeleccionada,
        'latitud': _ubicacionReal!.latitude,
        'longitud': _ubicacionReal!.longitude,
        'foto_url': imageUrl,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reporte creado con éxito")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Reporte")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("Ubicación detectada:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: _ubicacionObtenida 
                      ? FlutterMap(
                          options: MapOptions(
                            initialCenter: _ubicacionReal!,
                            initialZoom: 17,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                            MarkerLayer(markers: [
                              Marker(
                                point: _ubicacionReal!,
                                child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
                              ),
                            ]),
                          ],
                        )
                      : const Center(child: Text("Obteniendo GPS...")),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Captura de Foto (Corregido para Web/Móvil)
                  _imageFile == null && _webImage == null
                      ? ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Tomar Foto"),
                        )
                      : kIsWeb 
                        ? Image.memory(_webImage!, height: 150)
                        : Image.file(_imageFile!, height: 150),
                  
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(labelText: "Título del problema"),
                    validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _categoriaSeleccionada,
                    items: ['bache', 'luminaria', 'basura', 'alcantarilla', 'otro']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setState(() => _categoriaSeleccionada = v!),
                    decoration: const InputDecoration(labelText: "Categoría"),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Descripción detallada"),
                  ),
                  const SizedBox(height: 30),

                  MaterialButton(
                    minWidth: double.infinity,
                    height: 55,
                    color: AppColors.primary,
                    onPressed: _ubicacionObtenida ? _saveReport : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    child: const Text("Enviar Reporte", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}