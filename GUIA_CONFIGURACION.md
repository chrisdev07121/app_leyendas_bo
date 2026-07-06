# 📖 App Leyendas Bolivianas - Guía de Configuración Final

## 🎯 ¿Qué se implementó?

### Fase 1 - Pantalla Principal
✅ Cards de leyendas con información
✅ Filtro por departamento (Cochabamba por defecto)
✅ Pantalla de detalle con historia completa
✅ Datos de ejemplo de 8 leyendas

### Fase 2 - Autenticación y Creación
✅ Pantalla de login/registro
✅ Autenticación con Firebase Auth
✅ Crear nuevas leyendas
✅ Guardar en Firestore
✅ Carga de datos en tiempo real

## 🚀 Próximos Pasos

### 1️⃣ Instalar dependencias
```bash
flutter pub get
```

### 2️⃣ Configurar Firebase

**Opción A: Automática (Recomendado)**
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Seleccionar plataformas:
- ✓ Android
- ✓ iOS
- ✓ Windows
- ✓ macOS

**Opción B: Manual**

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
2. Proyecto: `leyendas-bolivianas`
3. Habilitar **Email/Password** en Authentication
4. Crear **Firestore Database** en modo test
5. Copiar valores a `lib/firebase_options.dart`

### 3️⃣ Configurar Firestore Security Rules

En Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /leyendas/{document=**} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### 4️⃣ Ejecutar la app
```bash
flutter run
```

## 📱 Estructura de Archivos

```
lib/
├── models/
│   ├── departamento.dart      # Modelo de departamentos
│   └── leyenda.dart           # Modelo de leyendas + datos ejemplo
├── screens/
│   ├── home_screen.dart       # Pantalla principal
│   ├── login_screen.dart      # Autenticación
│   ├── crear_leyenda_screen.dart # Crear leyendas
│   └── detalle_screen.dart    # Ver detalles
├── services/
│   ├── auth_service.dart      # Autenticación Firebase
│   └── leyenda_service.dart   # Firestore operations
├── firebase_options.dart      # Configuración Firebase
└── main.dart                  # Entry point + AuthWrapper
```

## 🔐 Flujo de Autenticación

```
Usuario no logueado
├── Ve leyendas públicas
├── Filtro por departamento funciona
└── Al hacer click en "Crear Leyenda" → Login

Usuario logueado
├── Ve leyendas públicas
├── Puede crear nuevas leyendas
├── Sus leyendas se guardan con su userId
└── Menú de usuario con opción logout
```

## 📊 Datos en Firestore

**Colección:** `leyendas`

**Estructura de documento:**
```json
{
  "userId": "uid-del-usuario",
  "titulo": "Nombre de la leyenda",
  "departamento": "cochabamba",
  "descripcionCorta": "Descripción breve",
  "descripcionLarga": "Historia completa",
  "imagen": "👻",
  "personajes": ["Personaje 1", "Personaje 2"],
  "origen": "Tradición del lugar",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## ✨ Características

- 📚 Ver leyendas públicas sin login
- 👤 Crear cuenta con email/contraseña
- 🔑 Recuperar contraseña
- ✍️ Crear nuevas leyendas (solo si logueado)
- 🏷️ Filtrar por 9 departamentos de Bolivia
- 📱 Interfaz responsiva y moderna
- 🔄 Carga de datos en tiempo real desde Firestore
- 💾 Datos locales como fallback

## 🐛 Posibles Errores y Soluciones

**Error: "Failed to initialize Firebase"**
- Revisar que firebase_options.dart tenga valores correctos
- Ejecutar `flutterfire configure` nuevamente

**Error: "Permission denied" al crear leyenda**
- Verificar Firestore Security Rules
- Asegurarse que el usuario está autenticado

**Error: "App not configured"**
- Ejecutar `flutter pub get`
- Limpiar build: `flutter clean`
- Recompilar: `flutter run`

## 📝 Notas

- Los datos locales son un fallback mientras configuras Firebase
- Una vez configurado, Firestore es la fuente de verdad
- Las leyendas creadas localmente no se sincronizarán a Firestore
- El archivo `firebase_options.dart` contiene datos públicos del proyecto

¡Listo para empezar! 🎉
