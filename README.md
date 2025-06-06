# Danleo - App de Gestión de Tienda de Ropa 👕

Aplicación Flutter para la gestión de productos, carrito de compras y geolocalización del local físico mediante Google Maps y GPS.

## 📱 Funcionalidades

- 🛍️ Catálogo de productos con imágenes, precios y descripciones
- 🛒 Carrito de compras funcional
- 🔄 Carga automática de datos (desde Firebase si se configura)
- 📍 Pantalla de "Ubícanos" con ruta real hasta el local
- 📦 Organización modular y navegación por Drawer

## 🧭 Dirección del local

Jr. Cajamarca 351, Huancayo 12001, Perú

## 🧱 Tecnologías usadas

- Flutter
- Google Maps API
- Geolocator
- Firebase (opcional)
- HTTP (para obtener rutas con Directions API)

---

## 🚀 Instalación y configuración para correr la app

### 1. Requisitos

- ✅ Flutter instalado (guía oficial: https://docs.flutter.dev/get-started/install)
- ✅ Android Studio o Visual Studio Code
- ✅ Emulador con Google Play Services o dispositivo físico

---

### 2. Clonar el repositorio

git clone https://github.com/Dewis2/danleo-flutter.git
cd danleo-flutter

---

### 3. Instalar dependencias

flutter pub get

---

### 4. Agregar tu archivo `google-services.json` (si usas Firebase)

1. Crea un proyecto en Firebase Console: https://console.firebase.google.com/
2. Descarga el archivo `google-services.json`
3. Colócalo en:

android/app/google-services.json

---

### 5. Configurar clave API de Google Maps

1. Entra a https://console.cloud.google.com/
2. Activa estas APIs:
   - Maps SDK for Android
   - Directions API
3. Crea una API Key
4. Pega tu clave en android/app/src/main/AndroidManifest.xml:

<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="TU_CLAVE_API" />

---

### 6. Ejecutar la app

flutter run

---

## 🧪 Simulación de ubicación (opcional)

Si usas un emulador y deseas simular que estás en Huancayo:

1. Abre el emulador
2. Clic en los tres puntos (...) en la esquina superior derecha
3. Ve a Location
4. Ingresa estas coordenadas:

Latitud: -12.0705
Longitud: -75.2048

---

## 🛠 Problemas comunes

Problema: Mapa no carga  
Solución: Revisa si tu API Key es válida y si activaste Maps API

Problema: MissingPluginException  
Solución: Ejecuta `flutter clean` y `flutter pub get`

Problema: GPS no funciona  
Solución: Verifica permisos de ubicación y que el GPS esté activo

Problema: No ves la ruta en "Ubícanos"  
Solución: Verifica que estés en la misma ciudad que la tienda o simula ubicación

---

## 👨‍💻 Autor

- Damian Wislee  
  Repositorio: https://github.com/Dewis2/danleo-flutter
