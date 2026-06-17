# Playbook L1 — WhatsApp / Customer Engagement (WABA) de Truora

> Fuente: conversaciones reales de soporte (HubSpot). Citas verbatim de los hilos.
> Bot de triage: **Truself** (`L-83860333`). Analistas humanos: Yeison (`A-78924545`), Lina (`A-83198633`), Paola (`A-60656017`).

## Qué es este producto y qué NO es

**Customer Engagement (WABA)** es el producto de Truora que opera sobre **WhatsApp Business API (WABA)**: el cliente B2B usa una o varias **líneas WABA** para enviar mensajes salientes (**Outbound / OTB**), correr **campañas / envíos masivos**, ejecutar **flujos de chatbot** sobre WhatsApp, y recibir conversaciones de sus usuarios finales (frecuentemente integradas a HubSpot). Las **plantillas de mensaje** deben ser aprobadas por **Meta** antes de poder enviarse.

Caso especial **WOM (Chile)**: combina engagement + identidad. El usuario final valida su identidad **dentro del chat WABA** y el cliente descarga la **VDI** (Validación De Identidad). Aquí el agente sí toca identidad, pero **solo en el contexto de la sesión de chat** (cerrar chat pegado, descargar el PDF de la VDI). Ver caso "WOM" abajo.

**Qué SÍ es alcance de este playbook:**
- Cerrar / finalizar sesiones o chats WABA "pegados".
- Plantillas rechazadas / pendientes de aprobación por Meta; plantilla que no aparece al enviar.
- Campañas / envíos masivos que fallan (errores de Meta vs. errores de flujo/config).
- Revisar logs / registro de envíos (estado de un OTB, razón de fallo de un número).
- Demoras o no-entrega atribuibles a **Meta** vs. a **Truora**.
- Integración del chatbot/flujo y su sincronización con HubSpot.
- WOM/Chile: cerrar chat pegado y descargar la VDI.

**Qué NO es (NO incluir aunque ocurra "dentro de WhatsApp"):**
- Una **validación de identidad** pura, un **check** de antecedentes o una **firma** (Truora Sign / ZapSign) NO son engagement. Si el cliente pide diagnosticar por qué un check no encontró registros, por qué un documento de firma da error, o desbloquear un `risky_face` → es otro producto. (Ej.: el bot Truself a veces contesta como si todo fuera ZapSign — ignóralo, eso es ruido de triage.)
- La descarga de la VDI **sí** es engagement (es el entregable del flujo WABA de WOM); el veredicto antifraude del rostro **no** lo es.

---

## Casos

### Cerrar / finalizar sesión o chat WABA "pegado" (alto volumen, rutinario)

- **Síntoma (como lo dice el cliente):** _«Hola, me pueden apoyar por favor cerrar la conversación de la WABA Line +5215549450043 con el usuario +521529541104966»_ · _«996460025 cerrar chat»_ · _«me ayudar a cerrar sesión del siguiente número 3108030712»_
- **Diagnóstico:** El usuario final quedó "atorado" en una sesión/conversación WABA y no puede reiniciar su proceso o recibir un nuevo Outbound. Resetear la sesión lo libera. Causa frecuente real: **el usuario no respondió con las opciones del flujo** → _«el usuario no esta respondiendo con las opciones del flujo, por eso no logra avanzar»_.
- **Solución estándar:** Identificar la **WABA Line** y el **número del usuario final**, finalizar la sesión desde la cuenta y confirmar. Es operación de un toque. Cita: _«Te confirmo que la sesión fue finalizada exitosamente.»_ (y en plural: _«Te confirmo que ambas sesiones fueron finalizadas exitosamente.»_). Si tras cerrar vuelve a aparecer bloqueado, revisar el contenido del Outbound y si el usuario está siguiendo las opciones del flujo.
- **Variante "ya estaba finalizada / no hay sesión activa":** si el número no tiene sesión abierta, comunicarlo y no forzar nada: _«actualmente el numero compartido no cuenta con una asesión activa.»_ Truself NO puede ejecutar esta acción y suele responder mal (manda al cliente a Meta Business Manager o a la app) — **siempre pasar a humano/tool**.
- **Cuándo escalar a humano:** Rara vez. Escalar a **SUP- (ingeniería)** solo si la sesión no se deja cerrar, vuelve a pegarse de inmediato sin causa de flujo, o el bloqueo persiste tras reset y reintento.

### Plantilla que no aparece al enviar / intermitente

- **Síntoma:** _«tengo una plantilla para envio pero al hacer el envio no la encuentra»_ · _«Ayer hice envíos con esas mismas y no me dió problemas»_ · _«Sucede intermitente ya que ahora la que no me quiere funcionar es otra plantilla»_
- **Diagnóstico:** La plantilla/Outbound (OTB) existe y está aprobada pero no se lista al buscarla en el selector de envío — comportamiento de UI/plataforma (no de Meta). Confirmado como bug de plataforma escalado a ingeniería.
- **Solución estándar:** Pedir el **ID del Outbound** (`OTB...`) para revisar el log. Workaround inmediato: _«la recomendación es escoger del listado los OTB»_ — bajar en la lista por scroll y escribir el nombre del outbound y dar Enter hasta encontrarlo. Verificar también que la plantilla esté **publicada (no borrador)** y sin variables vacías/nulas.
- **Cuándo escalar a humano:** Si está aprobada/publicada y aun así no aparece → escalar a **SUP- (ingeniería)** con el `OTB...`. (En el corpus se dio comportamiento intermitente con fecha estimada de solución.)

### Plantilla rechazada / pendiente de aprobación por Meta

- **Síntoma:** cliente pregunta por estado de aprobación de una plantilla, o por qué su mensaje de marketing no se entrega.
- **Diagnóstico:** Las plantillas las **aprueba o rechaza Meta**, no Truora. La aprobación es prerrequisito para enviar; el formato (variables entre llaves dobles, categoría correcta) afecta la aprobación.
- **Solución estándar:** Confirmar el estado de la plantilla (aprobada/publicada vs. borrador), revisar variables/categoría. Explicar que la decisión final de aprobación y de entrega depende de Meta. Si el rechazo es de criterio de Meta (categoría/contenido), el cliente debe ajustar el contenido y reenviar a revisión.
- **Cuándo escalar a humano:** Si es duda de política/categoría de Meta o el cliente necesita asesoría de buenas prácticas para evitar bloqueos → **comercial** (onboarding WABA) o referir a lineamientos de Meta. Bugs de la plataforma de plantillas → **SUP-**.

### Campaña / envío masivo que falla — error de Meta ("healthy ecosystem")

- **Síntoma:** _«presentamos error en los envíos de WhatsApp por Truora … Hemos realizado varios envíos de 500 mensajes pero el 95% de los mensajes son fallidos»_
- **Diagnóstico:** Error de Meta `"This message was not delivered to maintain healthy ecosystem engagement."` — política de Meta **"Límites de mensajes de plantillas de marketing"**. Cuando un usuario recibe varios mensajes de marketing sin interactuar, Meta lo interpreta como spam y **bloquea el envío 24h**; el análisis es **general (ecosistema), no cuenta-por-cuenta**. **Es de Meta, NO de Truora.**
- **Solución estándar (+ cita):** _«he estado revisando el reporte de las campañas y puedo ver que el error … es: "This message was not delivered to maintain healthy ecosystem engagement." Este mensaje es generado directamente por Meta y no por nuestra plataforma.»_ Recomendaciones: usar **otra línea** para los envíos, o **dar descanso de 24-48h** a la línea saturada. Otros errores de Meta que aparecen en logs: `"User's number is part of an experiment."` (Meta marca números al azar para no recibir Outbound → enviar a otro número).
- **Cuándo escalar a humano:** No se escala a ingeniería si la causa es Meta (no hay nada que arreglar del lado Truora). Solo escalar a **SUP-** si entre los fallos hay razones de Truora (ej. _«la línea utilizada no se encontraba correctamente registrada»_) o si la línea quedó mal registrada/aprovisionada.

### Campaña que falla por configuración del flujo (no es Meta)

- **Síntoma:** _«me podrían guiar para generar una campaña, ya que envié una y me ha generado un error»_
- **Diagnóstico:** Error de la propia campaña por flujo incompatible: `Invalid request: web flows cannot be used in whatsapp (10400)`. El cliente usó un **flujo Web** en una campaña de WhatsApp.
- **Solución estándar (+ cita):** Pedir el **ID de campaña** (`CPG...`). _«encuentro el siguiente error: Invalid request: web flows cannot be used in whatsapp (10400) Esto quiere decir que el flujo que estás usando … es un flujo Web, es decir no funciona para usarse como flow de WhatsApp para campañas.»_ Indicar que use un flujo cuyo **canal sea WhatsApp** (se define al crear el flujo).
- **Cuándo escalar a humano:** Normalmente se resuelve en L1. Escalar a **SUP-** solo si la config se ve correcta y el error persiste.

### Revisar logs / registro de envíos (estado de un Outbound por ID/número)

- **Síntoma:** _«mira que me estan reportando fallas de envio de whatsapp desde el 20 de octubre»_ · _«ese envío del 11, te sale rechazado?»_ · _«envié unos flujos, en mi backoffice me sale enviado pero al usuario final no le llega»_
- **Diagnóstico:** El cliente necesita la **razón de fallo por número**. Hay que leer el log de envíos y traducir el código a lenguaje claro, separando culpa Meta vs. Truora vs. lado-usuario.
- **Solución estándar:** Pedir el **número de ejemplo** y/o el **ID del Outbound** (`OTB...`) y revisar registro por registro. Reportar causa por número. Cita: _«Para el numero … se genero el fallo por la razón "This message was not delivered…". … todas las razones … a excepción de la línea no registrada correctamente son fallos directamente de Meta mas no de truora.»_ Si **no hay envíos registrados** para ese número, decirlo y pedir verificar el número o reintentar: _«para el numero que nos envías, no nos registra intentos de envió en los últimos días, puedes verificar si el numero esta correcto o intentar un nuevo envió.»_
- **Cuándo escalar a humano:** Si el cliente pide un **reporte agregado** (conteo de envíos/códigos de retorno por período) o un dump de logs → **SUP-** (lo arma ingeniería; SLA 1 a 5 días hábiles).

### Integración del chatbot / sincronización con HubSpot

- **Síntoma:** _«cuando nos escribe una persona este no esta transfiriendo al agente … no queda el registro con el nombre … en el sistema de hubspot»_ · _«uno de los flujos … para la recolección de la información de las personas por medio de whatsapp no esta quedando en el sistema de hubspot»_
- **Diagnóstico:** El flujo WABA recolecta datos del usuario (cédula, nombre, correo) y los escribe en HubSpot. Las propiedades **se actualizan de forma asíncrona**; demoras o no-aparición suelen ser del lado de HubSpot, no de Truora. También revisar si el contacto se está **duplicando** (cruce por celular/cédula).
- **Solución estándar (+ cita):** _«las propiedades … se actualizan de forma asíncrona, esto por demoras de Hubspot en la actualización; de nuestro lado se envía la solicitud de actualización sin embargo en ocasiones Hubspot se puede demorar.»_ Pedir ejemplos concretos (números, capturas de la hora de envío) para acotar y descartar duplicados.
- **Cuándo escalar a humano:** Si hay chats que **nunca llegan** a HubSpot o el flujo no transfiere a agente → recopilar varios ejemplos y escalar a **SUP- (ingeniería)**.

### WOM / Chile — VDI dentro del chat y cerrar chat pegado

- **Síntoma:** _«alguna inciden[cia], no se puede descargar vdi, se queda pensando y antes sale el error internal server error, ese chat es un ejemplo»_ · _«podrian ayudar cerrando este chat por favor 920904920»_
- **Diagnóstico:** Flujo combinado WOM: el usuario final valida identidad dentro del chat WABA y el cliente (ej. `andy.guerra@ventas.wom.cl`) descarga la **VDI** (PDF). El error de descarga suele ser de navegador/red del cliente; el cierre de chat es la operación rutinaria de reset de sesión.
- **Solución estándar (+ cita):** Para la VDI: pedir borrar cookies/caché, probar otro navegador o modo incógnito, revisar firewall/restricción de red. Mientras tanto, **el agente puede entregar el PDF directamente**: _«si necesitas el PDF, con gusto puedo ayudarte descargándolo … Te comparto el PDF del chat 56972563529.»_ Para cerrar chat: identificar el número y confirmar _«la conversación ha sido finalizada.»_
- **Cuándo escalar a humano:** El error de descarga `internal server error`, si afecta a varios ejecutivos, va a **SUP- (ingeniería)** (se vio `SUP-6454`). La parte de **por qué no se reconoció el rostro / no se extrajo el apellido** del usuario final es **identidad**, no engagement → derivar al flujo de identidad/revisión manual (no es alcance de este playbook).

### Demoras de entrega: Meta vs. Truora vs. operador móvil

- **Síntoma:** "los mensajes no llegan / llegan tarde", o el cliente sospecha caída del servicio.
- **Diagnóstico:** Distinguir capas. (a) **Meta**: bloqueos por política (healthy ecosystem, número en experimento) → es de Meta. (b) **Truora**: línea mal registrada/aprovisionada → arregla ingeniería. (c) **Lado usuario/operador**: el usuario no sigue el flujo, o hay incidencia externa (caída de operador móvil) que NO es del servicio Truora.
- **Solución estándar:** Leer el log y atribuir la causa explícitamente al cliente (los humanos no siempre lo hacen; el agente LLM **debe declarar la causa cuando la conozca**). Si la causa es Meta o el operador, gestionar expectativa (esperar / cambiar de línea / reintentar a otro número); no escalar a ingeniería.
- **Cuándo escalar a humano:** Solo si la causa atribuible a **Truora** (línea, plataforma) o si es una caída masiva confirmada → **SUP-**.

---

## Límites de seguridad / PII (evidenciado en los hilos)

- En el corpus circulan en texto plano por WhatsApp **números de líneas WABA, teléfonos de usuarios finales, cédulas, correos y nombres**. Es práctica observada pero **insegura**: minimizar PII y no exponer datos de usuarios finales de terceros.
- **No compartir documentos/datos del usuario final con el cliente** más allá de lo estrictamente operativo de su propia cuenta.
- El agente **solo verifica estado / ejecuta acciones operativas** sobre la línea o el chat del propio cliente; no realiza acciones sobre cuentas ajenas.
- No exponer el detalle interno de cómo Truora opera con Meta; la explicación al cliente se queda en "este fallo lo genera Meta por su política X".
- La **decisión antifraude** (rostro/identidad del usuario final en WOM) queda siempre fuera de engagement y en manos del equipo de identidad/revisión manual.

## Mesas de escalamiento

- **SUP- (ingeniería Truora):** plantilla aprobada que no aparece, línea mal registrada, chats que no llegan a HubSpot, error de descarga de VDI, reportes agregados de logs, caídas de plataforma. SLA típico comunicado: 1 a 5 días hábiles; se comparte el número de ticket y se da seguimiento proactivo.
- **Meta:** decisiones de aprobación/rechazo de plantillas y bloqueos por política (no hay ticket Truora; se gestiona expectativa y workaround).
- **Comercial:** activación/migración WABA, cotización, multiagente, opt-in/consentimiento, asesoría de políticas para evitar bloqueos.
- **NO escalar (resolver en L1):** cerrar/finalizar sesión, traducir un código de fallo de Meta, campaña con flujo Web mal elegido, "no hay sesión activa".
