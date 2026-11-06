# 🦊 HogarGo iOS

Versión iOS de **HogarGo**, la app para organizar el hogar en equipo: tareas compartidas, finanzas familiares, metas de ahorro y una mascota, **Zori**, que se cuida entre todos. Es el porte a **SwiftUI + SwiftData** de la app Android.

Microproyecto de la electiva **Desarrollo de Aplicaciones Móviles** — Departamento de Telemática, Universidad del Cauca.

## ✨ Funcionalidades

| Módulo | Qué hace |
|---|---|
| **Hogar y sesión** | Crear un hogar o unirse con un código. El administrador acepta o rechaza solicitudes. Inicio de sesión con código y *usuario de recuperación* (que también recupera el código del hogar). Perfil de integrantes y salir del hogar. |
| **Inicio** | Saludo, racha diaria, consejo del día (API en línea), Zori con su ropa, siguiente tarea, meta de ahorro y accesos rápidos. |
| **Tareas** | Crear tareas con categoría, fecha, recompensa en monedas y responsable. Completarlas alimenta la racha y las monedas. |
| **Finanzas** | Gastos por categoría, totales y desglose del mes, y varias metas de ahorro con aportes. |
| **Mascota** | Felicidad y saciedad que bajan con el tiempo, cuidado con cooldown, niveles, monedas y armario. |
| **Calendario** | Mes con puntos por día, detalle del día, próximos eventos y facturas con estado de pago. |
| **Notificaciones** | Recordatorio local a las 20:00 cuando la racha está en riesgo. |

Disponible en **español** e **inglés**. Además: bienvenida, "Acerca de" y créditos.

## 🧱 Arquitectura

Patrón **MVVM** sobre SwiftUI y SwiftData, en cuatro capas:

```text
Vista (SwiftUI)  →  ViewModel (@Observable)  →  Repositorio  →  SwiftData (ModelContext)
```

- **Vistas:** solo dibujan y reenvían acciones. Cada pestaña es un *wrapper* que crea su ViewModel y una vista de contenido que lo muestra.
- **ViewModels por pestaña** (`@Observable`, `@MainActor`): `HomeViewModel`, `TasksViewModel`, `FinanceViewModel`, `PetViewModel` y `CalendarViewModel`. Guardan el estado en propiedades y llaman a `reload()` tras cada acción.
- **`AppState` (global):** sesión, hogar activo, repositorios y avisos. Es el único estado compartido entre pestañas.
- **Repositorios:** reciben un `ModelContext`, hacen un solo `save()` por acción y deshacen (`rollback`) si falla.
- **`SaveObserver`:** cada ViewModel se suscribe a `ModelContext.didSave` para refrescarse cuando otra pantalla guarda (por ejemplo, completar una tarea desde Inicio actualiza Tareas).

Reglas que evitan datos viejos en pantalla: nunca se hace un `fetch` dentro de `body` (no se observa), el contexto tiene `autosaveEnabled = false` y todo dato lleva `householdId`.

## 📁 Estructura

```text
Sources/HogarGo/
├── App/            AppState, RootView, MainTabsView
├── Data/           Modelos SwiftData y repositorios (hogar, tareas, Finance/, Pet/, Calendar/)
├── ViewModels/     Un ViewModel por pestaña y SaveObserver
├── Views/          Pantallas por módulo (Welcome, Home, Tasks, Finance, Pet, Calendar, Profile)
├── Localization/   L10n y textos por módulo (sin .xcstrings)
├── Networking/     Consejo del día (Advice Slip API)
├── Notifications/  Avisos del hogar y recordatorio de racha
├── Resources/      Imágenes de Zori y del armario
└── Theme/          Colores
```

Las fechas se guardan como texto ISO `yyyy-MM-dd`. La sesión es lo único que va a `UserDefaults`.

## 🛠️ Tecnologías

- Swift 6 y SwiftUI (iOS 17)
- SwiftData para persistencia local
- `URLSession` + `Codable` para la API de consejos
- `UserNotifications` para el recordatorio de racha
- CryptoKit (SHA-256) para el usuario de recuperación
- xtool, Git y GitHub

## ▶️ Compilar y ejecutar

- **Mac con Xcode (recomendado):** abre el paquete (`Package.swift`) y ejecuta en un simulador con iOS 17 o superior.
- **Windows con WSL2 + xtool:** `./build.sh` sincroniza a `~/Developer/HogarGo` y compila. Los macros de SwiftData (`@Model`, `@Query`) **no compilan con xtool en Linux**, así que sirve solo para revisar lo que no los usa.

Identificador de la app: `co.edu.aplimovil.HogarGo` (`xtool.yml`). Icono en `Icon/AppIcon.png`.

## 🤝 Colaboración

`main` es la rama de integración. Cada integrante trabaja en su rama y los commits usan prefijos convencionales: `feat:`, `fix:`, `chore:`, `docs:`.
