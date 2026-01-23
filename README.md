🏙️ UrbanReport - Gestión Ciudadana Inteligente
UrbanReport es una aplicación móvil desarrollada con Flutter y Supabase que permite a los ciudadanos reportar problemas de infraestructura urbana (baches, luminarias, basura, etc.) de manera geolocalizada y en tiempo real.

📋 Módulos del Proyecto (Rúbrica)
La aplicación cumple con los siguientes requisitos técnicos:

Módulo 3.1: Autenticación: Login, Registro con metadatos (nombre completo) y persistencia de sesión.

Módulo 3.2: Base de Datos (CRUD): Creación, lectura, actualización y eliminación de reportes.

Módulo 3.3: Almacenamiento (Storage): Captura de fotos con la cámara y subida al Bucket de Supabase.

Módulo 3.4: Mapas y GPS: Ubicación automática del incidente mediante GPS y visualización en mapa interactivo.

📱 Funcionamiento y Arquitectura de Navegación
La aplicación utiliza una estructura de Navegación por Pestañas (Tabs) para organizar las 9 pantallas requeridas:

1. Sistema de Tabs (MainScreen)
Tab 1: Dashboard (Mis Reportes): Lista dinámica de reportes creados por el usuario. Implementa StreamBuilder para actualizaciones automáticas y RefreshIndicator para recarga manual (pull-to-refresh).

Tab 2: Mapa General: Visualización de todos los reportes activos en la ciudad. Incluye un Floating Action Button que abre la pantalla de creación de reportes.

Tab 3: Perfil: Muestra el nombre, correo y fecha de creación del usuario. Permite el cierre de sesión seguro.

2. Flujo de Creación de Reporte
Captura GPS: Al abrir el formulario, la app obtiene automáticamente la latitud y longitud con alta precisión.

Cámara: El usuario debe capturar una fotografía del incidente, la cual se previsualiza antes de enviarse.

Sincronización: La foto se sube a Supabase Storage y su URL pública se guarda en la base de datos junto con la descripción y ubicación.

🗄️ Configuración de la Base de Datos (SQL)
Para replicar este proyecto, ejecuta los siguientes scripts en el SQL Editor de Supabase:

Tablas y Tipos de Datos
Define las categorías de incidentes y la tabla principal de reportes:

SQL

-- Enums para integridad de datos
CREATE TYPE categoria_reporte AS ENUM ('bache', 'luminaria', 'basura', 'alcantarilla', 'otro');
CREATE TYPE estado_reporte AS ENUM ('pendiente', 'en_proceso', 'resuelto');

-- Tabla de Reportes
CREATE TABLE reportes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL,
  descripcion TEXT,
  categoria categoria_reporte DEFAULT 'otro',
  estado estado_reporte DEFAULT 'pendiente',
  latitud DOUBLE PRECISION NOT NULL,
  longitud DOUBLE PRECISION NOT NULL,
  foto_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
Gestión de Perfiles (Automatización)
Crea una tabla de perfiles que se llena automáticamente mediante un Trigger cuando un usuario se registra:

SQL

CREATE TABLE perfiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  nombre TEXT,
  correo TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Función Trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.perfiles (id, nombre, correo)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Disparador
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
🛠️ Instalación y Configuración
Dependencias: Asegúrate de que tu pubspec.yaml incluya supabase_flutter, flutter_map, geolocator, image_picker y latlong2.

Permisos:

Android: Configura ACCESS_FINE_LOCATION y CAMERA en el AndroidManifest.xml.

iOS: Añade NSLocationWhenInUseUsageDescription en Info.plist.

Storage: Crea un bucket público llamado fotos_reportes en Supabase y configura las políticas RLS (INSERT para usuarios autenticados y SELECT para todos).

Desarrollado para la materia de Desarrollo de Aplicaciones Móviles - Proyecto UrbanReport v1.0.0+1.
