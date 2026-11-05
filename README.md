# HogarGo-iOS

Aplicación iOS de HogarGo, la versión de la app Android para organizar las tareas del hogar y las finanzas de la familia con la mascota Zori. Está hecha con SwiftUI y SwiftData, y se puede preparar con xtool desde Windows con WSL2 o con Xcode en un Mac.

## Tecnologías

- Swift 6 y SwiftUI (iOS 17)
- SwiftData para guardar los datos en el dispositivo
- xtool, Git y GitHub
- Textos en español e inglés con `L10n.tr(es, en)` (sin `.xcstrings`)

## Pantallas

| Pestaña | Contenido |
|---|---|
| Inicio | Saludo, racha, consejo del día, Zori, siguiente tarea, meta de ahorro y accesos rápidos |
| Tareas | Lista de tareas del hogar, racha y alta de tareas nuevas |
| Finanzas | Gastos, metas de ahorro con frasco, totales del mes y desglose |
| Mascota | Zori: cuidado con cooldown, nivel, monedas y armario |
| Calendario | Mes con puntos, detalle del día, próximos eventos y facturas |

Además: bienvenida, crear o unirse a un hogar, iniciar sesión con código y usuario de recuperación, perfil de integrantes y "Acerca de".

## Estructura

```text
Sources/HogarGo/
├── App/            AppState, RootView, MainTabsView
├── Data/           Modelos SwiftData y repositorios (hogar, tareas, Finance/, Pet/, Calendar/)
├── Localization/   L10n y textos por módulo (L10n+Finance, +Pet, +Calendar, +Tasks)
├── Networking/     Consejo del día
├── Notifications/  Avisos del hogar y recordatorio de racha (20:00)
├── Resources/      Imagen de Zori
├── Theme/          Colores
└── Views/          Pantallas por módulo
```

Todos los datos llevan `householdId`: nada es global. Las fechas se guardan como texto ISO `yyyy-MM-dd`.

## Compilar

- **Mac con Xcode:** abre el paquete o usa `xtool dev`. Es la vía recomendada, porque SwiftData (`@Model`, `@Query`) no compila con xtool en Linux/WSL.
- **Windows con WSL2:** `./build.sh` sincroniza el proyecto a `~/Developer/HogarGo` y compila ahí (solo sirve para revisar lo que no usa macros de SwiftData).

El identificador de la app es `co.edu.aplimovil.HogarGo` (`xtool.yml`).

## Colaboración

`main` es la rama de integración. Cada integrante trabaja en su propia rama y los commits usan prefijos convencionales (`feat:`, `fix:`, `chore:`, `docs:`).
