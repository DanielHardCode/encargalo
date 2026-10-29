# Encárgalo

Encárgalo es un prototipo móvil offline-first para solicitar cotizaciones de productos personalizados en Piura. Permite registrar solicitudes, conservarlas localmente sin conexión, recibir cotizaciones simuladas y seguir el estado de un pedido.

Este proyecto corresponde al trabajo grupal de la Unidad 2 del curso **Tecnología y Desarrollo Móvil** de la Universidad Nacional de Piura.

## Funcionalidades implementadas

- Inicio de sesión local con roles de cliente y negocio.
- Navegación entre inicio, solicitudes, formulario, detalle, cotizaciones, seguimiento, sincronización y ajustes.
- Creación, consulta, edición y eliminación de solicitudes.
- Persistencia offline de solicitudes y cotizaciones mediante SQLite.
- Persistencia de sesión, rol, tema, modo de conexión y borradores mediante SharedPreferences.
- Gestión de estado con Provider y `ChangeNotifier`.
- Guardado temporal de campos del formulario cuando la aplicación pasa a segundo plano.
- Simulación de sincronización, recepción de cotizaciones y seguimiento del pedido.
- Tema claro y oscuro.

## Stack tecnológico

| Tecnología | Uso |
| --- | --- |
| Flutter | Interfaz y aplicación móvil para Android |
| Dart `^3.8.1` | Lenguaje de programación |
| Provider `^6.1.5+1` | Gestión reactiva del estado |
| sqflite `^2.4.2` | Base de datos SQLite local |
| shared_preferences `^2.5.3` | Sesión, configuración y borradores simples |
| path `^1.9.1` | Construcción de la ruta de la base de datos |
| flutter_lints `^5.0.0` | Reglas de análisis estático |

## Requisitos

Antes de ejecutar el proyecto, instalá:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible con Dart 3.8.1 o superior.
- Android Studio o un dispositivo Android con depuración USB habilitada.
- Git.

Comprobá el entorno con:

```bash
flutter doctor
```

## Instalación y ejecución

```bash
git clone https://github.com/DanielHardCode/encargalo.git
cd encargalo
flutter pub get
flutter run
```

Para seleccionar un dispositivo disponible:

```bash
flutter devices
flutter run -d <device-id>
```

## Compilación para Android

Generá un APK de depuración con:

```bash
flutter build apk --debug
```

Generá un APK de distribución local con:

```bash
flutter build apk --release
```

El resultado se crea dentro de `build/app/outputs/flutter-apk/`.

## Flujo principal de demostración

1. Iniciar sesión como cliente.
2. Desactivar el modo de conexión desde **Ajustes**.
3. Crear una solicitud con sus datos y una foto simulada.
4. Consultar, editar y eliminar solicitudes almacenadas localmente.
5. Cerrar y volver a abrir la aplicación para comprobar la persistencia.
6. Activar nuevamente el modo de conexión.
7. Ejecutar la sincronización simulada para generar cotizaciones.
8. Aceptar una cotización y avanzar el seguimiento del pedido.

## Persistencia local

| Información | Almacenamiento |
| --- | --- |
| Solicitudes | SQLite, tabla `solicitudes` |
| Cotizaciones | SQLite, tabla `cotizaciones` |
| Usuario y rol | SharedPreferences |
| Tema y modo de conexión | SharedPreferences |
| Borrador temporal del formulario | SharedPreferences |

La entidad principal, `Solicitud`, dispone de operaciones de creación, lectura, actualización y eliminación. Las operaciones de base de datos son asíncronas para no bloquear la interfaz.

## Arquitectura

```text
lib/
├── data/       # Acceso asíncrono a SQLite
├── models/     # Solicitudes, cotizaciones y estados
├── screens/    # Pantallas y rutas de navegación
├── state/      # Estado global con Provider y ChangeNotifier
├── widgets/    # Componentes reutilizables
└── main.dart   # Configuración e inicio de la aplicación
```

El flujo principal es:

```text
Pantalla → AppState (Provider) → AppDatabase / SharedPreferences
```

## Integrantes y responsabilidades

| Integrante | Responsabilidad principal |
| --- | --- |
| Lertua Coico Joel Sebastian | Interfaz de usuario y navegación |
| Macalupú Chavez Jeancarlos Daniel | Gestión de estado e integración del prototipo |
| Pulache Pulache Jaime Jonathan | Persistencia SQLite y operaciones CRUD |
| Orihuela López José Miguel | Pruebas funcionales, documentación y exposición |

Las responsabilidades representan el reparto acordado para completar y sustentar la entrega. El equipo debe conservar commits identificables de cada integrante en el historial del repositorio.

## Verificación del código

Ejecutá el análisis estático antes de entregar:

```bash
flutter analyze
```

También se debe comprobar manualmente en un emulador o dispositivo:

- Navegación y paso de datos entre pantallas.
- Validaciones y eventos de la interfaz.
- CRUD completo de solicitudes.
- Persistencia después de cerrar y reabrir la aplicación.
- Recuperación del borrador al enviar la aplicación a segundo plano.
- Preferencias de sesión, tema y conexión.

## Alcance actual y simulaciones

Este repositorio contiene un **prototipo académico local**. Para presentar sus capacidades con precisión:

- El inicio de sesión es local y no autentica contra un servidor.
- El interruptor de conexión simula el estado online/offline.
- La sincronización y las cotizaciones se generan localmente.
- La acción de agregar una foto genera una referencia simulada; todavía no captura ni cifra archivos reales.
- No hay backend, pagos, chat, notificaciones push ni despliegue comercial.

Estas funciones no son necesarias para demostrar el objetivo de persistencia offline de la Unidad 2.

## Entrega académica

Además del repositorio, la consigna requiere:

- Un video de máximo cinco minutos que muestre navegación, eventos y persistencia SQLite después de cerrar y reabrir la aplicación.
- Una demostración en emulador o dispositivo físico.
- Una explicación del flujo de información y la arquitectura de almacenamiento local.
- Historial de commits que evidencie la participación de todos los integrantes.

## Licencia

Proyecto académico desarrollado para el curso Tecnología y Desarrollo Móvil. No se ha definido una licencia de distribución pública.