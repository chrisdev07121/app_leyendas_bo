# 🔧 Configuración de Firebase

## Pasos para Configurar Firebase en tu Proyecto

### 1. Crear Proyecto en Firebase Console
1. Ir a [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click en "Crear un proyecto"
3. Ingresar nombre: `leyendas-bolivianas`
4. Continuar con la configuración

### 2. Instalar Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 3. Configurar FlutterFire
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Seleccionar:
- ✓ Android
- ✓ iOS  
- ✓ Windows
- ✓ macOS
- ✓ Web (opcional)

### 4. Habilitar Autenticación

En Firebase Console:
1. Ir a **Authentication** → **Sign-in method**
2. Habilitar **Email/Password**
3. Click **Enable** y **Save**

### 5. Configurar Firestore Database

En Firebase Console:
1. Ir a **Firestore Database**
2. Click **Create Database**
3. Seleccionar ubicación (ej: América del Sur)
4. Seleccionar **Start in test mode**

Una vez creado, actualizar **Security Rules**:

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

### 6. Actualizar firebase_options.dart

El archivo `lib/firebase_options.dart` se generará automáticamente con `flutterfire configure`.
Si lo generaste manualmente, reemplaza los valores placeholder con los reales de tu proyecto Firebase.

## ✅ Verificación

Después de configurar:
1. Ejecutar `flutter pub get`
2. Ejecutar `flutter run`
3. Probar registro/login

## 🚀 Estructura de Firestore

Colección: `leyendas`

Documento structure:
```json
{
  "userId": "uid del usuario",
  "titulo": "Nombre de la leyenda",
  "departamento": "cochabamba",
  "descripcionCorta": "Descripción breve",
  "descripcionLarga": "Descripción completa",
  "imagen": "👻",
  "personajes": ["Personaje 1", "Personaje 2"],
  "origen": "Tradición del lugar",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 📱 Características Implementadas

✅ **Autenticación**
- Registro con email y contraseña
- Inicio de sesión
- Recuperación de contraseña
- Cierre de sesión

✅ **Leyendas**
- Ver leyendas públicas (no requiere login)
- Crear leyendas (requiere login)
- Filtrar por departamento
- Ver detalles de leyenda

✅ **Persistencia**
- Datos en Firestore
- Datos locales como fallback
