# FitManager – App Flutter + NetBeans

## Estructura del proyecto Flutter

```
lib/
├── main.dart                    ← Entrada: Splash → Home
├── theme.dart                   ← Paleta de colores y temas
├── config.dart                  ← URL del backend (configurable)
├── models/
│   └── app_user.dart            ← Modelo Usuario alineado con la BD
├── services/
│   └── api_service.dart         ← Cliente HTTP hacia MobileApiServlet
├── widgets/
│   └── brand_logo.dart          ← Logo de la app
└── screens/
    ├── splash_screen.dart       ← Animación de carga con el logo
    ├── home_screen.dart         ← Pantalla de inicio (Login / Registrar)
    ├── login_screen.dart        ← Formulario de login
    ├── register_screen.dart     ← Formulario de registro
    └── admin_screen.dart        ← Panel admin con lista de usuarios
```

## Paso 1 – Agregar el servlet al proyecto NetBeans

1. Copia **MobileApiServlet.java** a:
   ```
   src/java/servlet/MobileApiServlet.java
   ```
2. Haz **Clean and Build** en NetBeans.
3. Despliega en GlassFish o Tomcat (puerto 8080 por defecto).

## Paso 2 – Configurar la URL en Flutter

Abre `lib/config.dart` y ajusta la URL según tu entorno:

| Entorno | URL |
|---|---|
| Emulador Android | `http://10.0.2.2:8080/FitManager/MobileApiServlet` (ya configurado) |
| Celular físico | `http://192.168.X.X:8080/FitManager/MobileApiServlet` |

**Nota:** Reemplaza `192.168.X.X` con la IP de tu PC en la misma red Wi-Fi.
Para obtenerla: `ipconfig` (Windows) o `ifconfig` (Mac/Linux).

También puedes usar `--dart-define` al correr la app:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8080/FitManager/MobileApiServlet
```

## Paso 3 – Instalar dependencias Flutter

```bash
cd fitmanager_final
flutter pub get
flutter run
```

## Flujo de la app

```
Splash (logo animado)
    ↓
Home (Inicio)
    ├── Iniciar sesión → Login → Panel Admin (solo admins)
    └── Registrarse   → Formulario de registro → vuelve a Login
```

## Notas importantes

- La base de datos usa **puerto 3307** (como en tu Conexion.java).
- El servlet no maneja verificación de correo (eso lo hace el sistema web).
- Los tokens de sesión son en memoria (se borran al reiniciar el servidor).
- Solo usuarios con `id_Roles = 1` (Administrador) pueden acceder al panel admin.
- Los administradores no se pueden eliminar desde la app móvil.
