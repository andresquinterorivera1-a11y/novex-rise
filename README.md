# NOVEX RISE

**No sigas el scroll, marca tu ritmo.**

App para iPhone que te pone una **pausa consciente** antes de entrar a una red social:
respiras, decides si de verdad quieres entrar, eliges cuánto tiempo y la app te avisa
cuando se acaba. Diseño 100 % blanco y negro para desintoxicar la mente.

---

## Qué versión es esta: NOVEX RISE Lite (gratis, sin Mac)

Apple solo deja usar la **Screen Time API** (el bloqueo "de verdad", con Shield) a
quien paga la cuenta de Apple Developer (99 USD al año). Con una cuenta gratis,
Xcode rechaza ese permiso.

Por eso esta primera versión usa lo que **sí es gratis**:

| Función | Cómo lo hace la versión Lite |
|---|---|
| Detectar que abriste Instagram, TikTok, etc. | Automatización de la app **Atajos** de Apple |
| Pausa consciente (respiración, pregunta, tiempo, intención) | Pantalla completa de NOVEX RISE |
| No repetir la pausa si ya elegiste tiempo | Acción de Atajos «¿Puedo entrar?» |
| Cuenta regresiva | **Live Activity** en la pantalla de bloqueo e Isla Dinámica |
| Aviso 1 minuto antes y al terminar | Notificaciones locales |
| «¿Sales o necesitas 2 minutos más?» | Botones en la notificación (1 extensión por sesión) |
| Estadísticas básicas | Gráfica de 7 días, por app y por intención |

**Limitación honesta:** sin Screen Time API, NOVEX RISE no puede *expulsarte* de la
app cuando se acaba el tiempo. Te avisa, y la próxima vez que la abras vuelve la
pausa. El código está preparado para añadir el bloqueo real cuando tengas la cuenta.

---

## Estructura del proyecto

```
project.yml                    ← Define el proyecto (XcodeGen). Sustituye al .xcodeproj
.github/workflows/ios.yml      ← Compila la app gratis en un servidor macOS de GitHub
NovexRise/
  App/          NovexRiseApp, AppDelegate (notificaciones), AppRouter (navegación)
  Model/        ControlledApp, NovexStore (datos), Stats, Quotes (101 frases)
  Services/     NotificationService, LiveActivityService, AppLauncher
  Intents/      Acciones de Atajos: «¿Puedo entrar?» y «Abrir pausa consciente»
  UI/           Theme, Components, Root, Pause/, Onboarding/, Tutorial/, Home/, Stats/, Settings/
  Resources/    Assets (ícono blanco y negro)
NovexRiseWidgets/              ← Live Activity (pantalla de bloqueo + Isla Dinámica)
Shared/                        ← Código compartido entre app y widget (logo, datos de la Live Activity)
```

Todos los datos se guardan **solo en el iPhone** (UserDefaults). No hay servidores,
cuentas ni rastreo.

---

## Cómo compilar e instalar SIN Mac y SIN pagar

Necesitas: tu PC con Windows, tu iPhone, su cable y una cuenta gratis de GitHub.

### 1. Sube el proyecto a GitHub

1. Crea una cuenta gratis en <https://github.com>.
2. Crea un repositorio nuevo llamado `novex-rise` (vacío, sin README).
   - **Público**: compilaciones ilimitadas gratis.
   - **Privado**: el plan gratis da 2.000 minutos al mes, pero macOS cuenta x10,
     así que salen unas 25–35 compilaciones al mes. Suficiente para empezar.
3. En PowerShell, dentro de esta carpeta:

```powershell
git init -b main
```

```powershell
git add .
```

```powershell
git commit -m "NOVEX RISE Lite: MVP"
```

```powershell
git remote add origin https://github.com/TU_USUARIO/novex-rise.git
```

```powershell
git push -u origin main
```

### 2. Deja que GitHub compile la app

1. En tu repositorio, abre la pestaña **Actions**. Verás «Compilar NOVEX RISE (iOS)» en marcha.
2. Tarda unos 5–10 minutos. Si sale ✅, entra al resultado y descarga
   **NovexRise-ipa** (es un .zip que contiene `NovexRise.ipa`).
3. Si sale ❌, abre el paso en rojo, copia el error y pásamelo: lo corregimos.

### 3. Instala el .ipa en tu iPhone desde Windows

Usaremos **Sideloadly** (gratis), que firma la app con tu Apple ID gratuito.

1. Instala **iTunes** desde la web de Apple (versión de escritorio, no la de Microsoft Store).
2. Descarga Sideloadly solo desde su web oficial: <https://sideloadly.io>.
3. Conecta el iPhone por cable y toca **Confiar** en el iPhone.
4. Abre Sideloadly, arrastra `NovexRise.ipa`, escribe tu Apple ID y pulsa **Start**.
   - Recomendación: usa un Apple ID secundario si no quieres usar el principal.
5. En el iPhone:
   - **Ajustes → Privacidad y seguridad → Modo de desarrollador → Activar** (se reinicia).
   - **Ajustes → General → VPN y gestión de dispositivos →** toca tu Apple ID → **Confiar**.

> Con un Apple ID gratis la app dura **7 días**. Para renovarla, vuelve a pasarla con
> Sideloadly (tus datos se conservan si no la borras). Sideloadly también puede
> renovarla sola si dejas su servicio activo y el iPhone en la misma red Wi‑Fi.
> Límite gratis: 3 apps instaladas así a la vez.

### 4. Primer uso

1. Abre NOVEX RISE y completa las 5 pantallas: bienvenida → metas → apps → avisos → tutorial.
2. Sigue el tutorial para crear **una sola** automatización en **Atajos** para todas tus apps.

   **iOS 26 o posterior** (una acción):

   ```
   Cuando «Instagram», «TikTok», «YouTube»… se abra  (Ejecutar inmediatamente)
     Pausa NOVEX RISE                               ← acción de NOVEX RISE
   ```

   **iOS 18 o anterior** (dos acciones y un «Si»):

   ```
   Cuando «Instagram», «TikTok», «YouTube»… se abra  (Ejecutar inmediatamente)
     1. ¿Puedo entrar?                              ← acción de NOVEX RISE
     2. Si [Resultado] es «pausa»
          Abrir pausa consciente                    ← acción de NOVEX RISE
        Fin de si
   ```

3. Abre Instagram: debe aparecer la respiración de NOVEX RISE y luego
   «¿Qué app ibas a abrir?».

**Si las acciones de NOVEX RISE no aparecen en Atajos:** abre NOVEX RISE una vez,
ciérrala y vuelve a buscar «NOVEX RISE» en las acciones.

---

## Pantallas del MVP

1. **Respiración guiada** (5–10 s, no se puede saltar), círculo que se expande y se contrae.
2. **¿De verdad quieres entrar?**: cuántas veces lo intentaste hoy, tu meta
   («¿Esto te acerca a tu meta?») y una frase distinta en cada pausa.
3. **¿Cuánto tiempo?**: 1, 5, 10, 15 o 30 minutos, u otro (1–120).
4. **¿Para qué vas a entrar?** (opcional): mensajes, algo específico o aburrimiento.
5. **Se acabó tu tiempo**: «Salgo, subo de nivel» o «2 minutos más» (una vez por sesión).
6. **Inicio**: sesión activa, resumen del día, frase del día, apps y botón para probar la pausa.
7. **Estadísticas**: hoy / 7 días, gráfica por día, comparación con la semana anterior,
   por app y por intención.
8. **Ajustes**: apps, metas, duración de la respiración, tutorial y privacidad.

---

## Lo que viene después

- Niveles (Despertar → Enfocado → Imparable), puntos, rachas e insignias.
- Tiempo recuperado.
- Límites diarios por app, horarios (trabajo, estudio, sueño) y **Modo RISE** (25/50/90 min).
- Widget de inicio con racha, nivel y frase del día.
- Recordatorios y resumen semanal.
- **Versión completa con Screen Time API** (ver abajo).

---

## Cuando puedas pagar Apple Developer: versión completa

Con la cuenta de 99 USD/año se añaden las extensiones de Screen Time (Shield
personalizado, ShieldAction, DeviceActivityMonitor, DeviceActivityReport) y el
App Group, y la app puede **bloquear de verdad**.

Pasos para pedir el permiso `com.apple.developer.family-controls` para distribución:

1. Inscríbete en el **Apple Developer Program**.
2. Para probar en tu iPhone basta con añadir la capacidad **Family Controls** en el
   proyecto: el permiso de *desarrollo* se concede al momento.
3. Para publicar, pide el permiso de *distribución* en
   <https://developer.apple.com/contact/request/family-controls-distribution>.
   Explica que es una app de bienestar digital para uso personal (`.individual`), que
   los datos de Screen Time no salen del dispositivo y para qué usas cada extensión.
4. Apple lo aprueba por identificador de app. Pídelo para la app **y para cada
   extensión** que use Screen Time. Suele tardar de días a semanas.
5. Cuando lo aprueben, actívalo en *Certificates, Identifiers & Profiles → Identifiers →
   (tu App ID) → Additional Capabilities → Family Controls (Distribution)*.

Para la App Store también necesitarás una política de privacidad pública, la ficha de
privacidad («Datos no recopilados») y notas de revisión que expliquen cómo probar la app.
