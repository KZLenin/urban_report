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
