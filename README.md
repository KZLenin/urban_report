# 🏙️ UrbanReport - Gestión Ciudadana Inteligente

**UrbanReport** es una solución móvil multiplataforma desarrollada con **Flutter** y **Supabase** que permite a los ciudadanos reportar incidentes urbanos (baches, luminarias, basura, etc.) de manera geolocalizada y en tiempo real.

## 📋 Módulos del Proyecto (Rúbrica)

La aplicación cumple con los siguientes requisitos técnicos establecidos en la rúbrica del proyecto:

* **Módulo 3.1: Autenticación**: Registro e inicio de sesión con persistencia de datos mediante Supabase Auth.
* **Módulo 3.2: Base de Datos (CRUD)**: Gestión completa (Crear, Leer, Actualizar, Eliminar) de los reportes ciudadanos.
* **Módulo 3.3: Almacenamiento (Storage)**: Captura de fotos mediante la cámara y carga de archivos al Bucket de Supabase.
* **Módulo 3.4: Mapas y GPS**: Ubicación automática del incidente por GPS y visualización interactiva con OpenStreetMap.

---

## 📱 Funcionamiento y Navegación (Tabs System)

La aplicación organiza sus funciones principales a través de un sistema de **pestañas (BottomNavigationBar)** para una navegación fluida entre las 9 pantallas requeridas:

### 1. Dashboard (Mis Reportes)
* Visualiza exclusivamente los reportes creados por el usuario autenticado.
* Implementa `StreamBuilder` para reflejar cambios en la base de datos de forma instantánea.
* Incluye la función **"Deslizar para recargar"** (RefreshIndicator) para actualizaciones manuales.

### 2. Mapa General y Creación
* Visualización de todos los reportes activos en un mapa dinámico.
* **Creación de Reportes**: Al abrir el formulario, la app captura automáticamente la ubicación GPS exacta del momento sin permitir la modificación manual del marcador, garantizando la veracidad del reporte.

### 3. Perfil de Usuario
* Muestra información del ciudadano: nombre completo, correo electrónico y fecha de creación de la cuenta.
* Gestión de sesión: Opción de cierre de sesión seguro para proteger la identidad del usuario.



---

## 🗄️ Configuración de la Base de Datos (SQL)

Para replicar la infraestructura en Supabase, ejecute los siguientes scripts en el **SQL Editor**:

### Definición de Tablas y Enums
```sql
-- Tipos de datos personalizados
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
```

### Gestión de Perfiles (Automatización)
```sql
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
```

## 🛠️ Instalación y Configuración
### Dependencias: 
  * Asegúrate de que tu pubspec.yaml incluya supabase_flutter, flutter_map, geolocator, image_picker y latlong2.
### Permisos:
  * Android: Configura ACCESS_FINE_LOCATION y CAMERA en el AndroidManifest.xml.
  * iOS: Añade NSLocationWhenInUseUsageDescription en Info.plist.
### Storage: 
  * Crea un bucket público llamado fotos_reportes en Supabase y configura las políticas RLS (INSERT para usuarios autenticados y SELECT para todos). 
## 📥 Descarga de la Aplicación

Debido al peso de la aplicación y la inclusión de módulos de Mapas y GPS, puedes descargar el instalador desde el siguiente enlace:

> [!IMPORTANT]
> **Versión**: 1.0.0+1
> **Requisito**: Habilitar permisos de GPS y Cámara para el funcionamiento de los Módulos 3.3 y 3.4.

[📦 Descargar UrbanReport APK](https://epnecuador-my.sharepoint.com/:u:/g/personal/lenin_taco_epn_edu_ec/IQAECYaT2b8FRKRgtoT17WqCAScOitFi8-NAlM_BER0eQT8?e=1rsJVh)
