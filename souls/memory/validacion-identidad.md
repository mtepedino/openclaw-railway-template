# Playbook L1 — Validación / Identidad Digital (Truora)

> Contexto de soporte para un agente L1. Basado en conversaciones reales de WhatsApp/chat web.
> IDs de ejemplo: proceso `IDP...`, flujo `IPF...`, cuenta `...DI...` / `CC.../CE...`, validación `VLD...`, enrollment `ENR...`, ticket de ingeniería `SUP-`.

## Qué es este producto y qué NO es

**Identidad Digital (DI)** es el producto donde un usuario final demuestra que es quien dice ser. Tiene dos entidades que **no debes confundir**:

> **Proceso (`IDP…`) ≠ Validación (`VLD…`).** Un **proceso de Identidad Digital** (`IDP…`) es el flujo completo que vive un usuario; **contiene una o más validaciones** (`VLD…`), cada una de un **tipo** distinto. Un mismo proceso puede tener una validación de documento exitosa y una validación facial fallida. Cuando el cliente dice "la validación falló", aclara **cuál validación** (qué tipo) dentro de **cuál proceso** (`IDP…`).

Tipos de validación que puede contener un proceso (confirmados en el modelo de datos):
- **Validación de documento** (OCR/extracción): cédula CC, cédula de extranjería CE, PPT, pasaporte…; se extrae texto y se valida contra bases de gobierno.
- **Reconocimiento facial / similaridad (TruFace)** y **liveness:** se compara el rostro vivo contra la foto del documento y contra la colección de la cuenta.
- **Búsqueda de rostro (face-search)** contra la base global (origen de `risky_face`).
- **Validación de email** y **de teléfono** (OTP).
- **Firma electrónica** (cuando es parte del flujo DI).
- **Validación contra base de gobierno.**

Además existen: **enrolamiento / desenrolamiento** (`ENR…`, crear/borrar el registro biométrico base), el **flujo configurado** (`IPF…`, la plantilla del proceso) y estados del proceso ("validando", pendiente, rechazado).

Regla de captura: identifica siempre el **proceso (`IDP…`)** y, si el cliente habla de una validación puntual, la **validación (`VLD…`)** y su **tipo**. Con eso (más el nombre de la empresa) puedes diagnosticar y, si toca, escalar.

**Esto NO es, y se deriva a otra mesa / producto:**
- **CHECK / antecedentes** (score, homonimia, consulta penal/judicial) → producto Background Checks. Otro playbook.
- **Firma electrónica:** la firma nativa del flujo DI (OTP, dibujar/escribir firma en el chatbot) sí toca identidad; pero ZapSign como plataforma de firma se deriva a **ZSUP-**. Si la duda es sobre el documento firmado, posicionamiento de firma, prefijo de firmante, etc., es Sign, no identidad.
- **WhatsApp Business / campañas / plantillas / engagement** → otro equipo.

Regla práctica: si la conversación gira en torno a **rostro, documento, selfie, enrollment, "validando", `risky_face`, `missing_text`, OCR** → es identidad y es tu alcance.

---

## Casos comunes

### 1. `risky_face_detected` — rostro reportado en base global de fraude
- **Síntoma (cliente):** _«el cliente al realizar el proceso biométrico le asigna un motivo de rechazo (Señal de riesgo detectada → Usuario con múltiples documentos)»_ · _«todos los proceso de allí en adelante les queda signado Motivo de rechazo risky_face_detected»_ · "¿me confirmas el motivo de rechazo de este cliente?".
- **Diagnóstico:** el rostro coincide con un enrollment ya **reportado en la base global de rostros fraudulentos (TruFace global)**, o con un usuario ya marcado en la colección de la cuenta. Es una **decisión antifraude**, no un fallo de calidad.
- **Solución estándar:** NO desbloquear ni eliminar el reporte por iniciativa propia. Recopilar el caso, encolar a **revisión manual antifraude** y comunicar el veredicto. Si el cliente insiste en que es un falso positivo, debe escalarlo por correo a su representante/CSM con copia (no se desbloquea por chat).
  > _«por seguridad no se debe eliminar el reporte de la base global truface y manejar este caso como un rechazo por Risky Face Detected. Si ustedes consideran que es un error… se debe enviar un correo con esa solicitud, con copia a [CSM] de Truora.»_
- **Cuándo escalar a humano:** **SIEMPRE.** La decisión de mantener/levantar un `risky_face` es del **equipo de revisión manual antifraude**, nunca del agente. El L1 solo recopila y encola.

### 2. "Foto de foto" / documento alterado — sospecha de fraude
- **Síntoma (cliente):** "no me deja desbloquear este usuario", "¿por qué quedó rechazado?".
- **Diagnóstico:** durante el análisis se detecta **foto de una foto** del documento, holograma/leyendas borrosas, fechas inconsistentes (p.ej. expedición antes de los 18) u otros indicios de manipulación → indicio de fraude.
- **Solución estándar:** no se habilita al usuario. Se explica el motivo sin exponer datos del usuario final.
  > _«no fue posible proceder con el desbloqueo, ya que durante el análisis se identificó un indicio de fraude correspondiente a foto de foto, lo cual impide habilitar nuevamente al usuario.»_
- **Cuándo escalar a humano:** **SIEMPRE** queda en revisión manual antifraude. Si el cliente reporta un patrón recurrente o pide activar **Manual Review** para su cuenta, escalar a **SUP-** / CSM (caso de configuración + antifraude).

### 3. Documento rechazado por OCR (`missing_text`, texto incompleto, calidad)
- **Síntoma (cliente):** _«no le están pasando con el error missing_text, es una CE y el user ya volvió a tomar las fotos pero no se le aceptan»_ · "el documento no pasa", "sigue generando error".
- **Diagnóstico:** el OCR no logra extraer todos los campos. Causas típicas (lado usuario): **foco de luz / reflejo sobre los datos**, contraluz que activa **holograma/marcas de agua** tapando la foto, fondo inadecuado, documento cortado, o **tipo de documento mal seleccionado**.
- **Solución estándar:** consultar el `VLD/IDP`, identificar qué campo no se extrae y dar instrucción concreta de recaptura; pedir un **proceso nuevo** para validar con un registro reciente.
  > _«continúa tomando la foto teniendo un foco de luz a un costado del documento justo en los datos de las fechas, lo que impide su correcta extracción; recomendamos que el usuario mejore la toma de fotos y evite focos de luz sobre el documento.»_ · _«intente tomar la foto con un fondo diferente, veo que no logra extraer algunos datos.»_
- **Cuándo escalar a humano:** si el OCR falla sistemáticamente con buena foto, o se sospecha que falla por **tipo de documento mal soportado/seleccionado** → **SUP- ingeniería**. Recuérdale al cliente que cada reintento puede consumir intentos.

### 4. "Rostro no detectado"
- **Síntoma (cliente):** "el proceso falla / no avanza en la selfie", "¿recomendación para este cliente?".
- **Diagnóstico:** la captura de selfie no localiza un rostro válido: contraluz, fondo cargado, baja luz o encuadre.
- **Solución estándar:** instrucción de recaptura.
  > _«los procesos han sido fallidos por "Rostro no detectado". Te recomiendo que intenten en un fondo neutro, puede ser de color oscuro y con buena luz pero no a contraluz.»_
- **Cuándo escalar a humano:** solo si con buena captura persiste el fallo → **SUP-**.

### 5. "Similaridad entre rostros fallida"
- **Síntoma (cliente):** "el usuario firmó pero aparece rechazado", "no le permite continuar".
- **Diagnóstico:** el modelo no encuentra coincidencia entre la **selfie** y la **foto impresa del documento**. Dos causas frecuentes: (a) holograma/marcas de agua interfieren en la foto por contraluz; (b) **dos personas comparten el mismo `account_id`/ID de cuenta**, por lo que un rostro se compara contra el documento del otro, o el flujo se envió a la persona equivocada.
- **Solución estándar:** si es calidad → recaptura. Si es ID de cuenta compartido o flujo mal enviado → **eliminar el enrollment** y rehacer el proceso con cada persona por separado.
  > _«El modelo no encuentra similitud entre la selfie de esta persona y la foto impresa en el documento. Veo que el holograma y las marcas de agua interfieren… recomiendo un nuevo proceso con mejores fotos.»_ · _«Lo que procede es eliminar el registro o enrollment y que las dos personas hagan de nuevo el proceso.»_

### 6. Desenrolamiento (borrar enrollment facial)
- **Síntoma (cliente):** _«me ayudas por favor a desenrolar este proceso: IDP…»_ · "el usuario no puede repetir la validación".
- **Diagnóstico:** el enrollment existente impide rehacer el proceso (usuario quedó "pegado", account_id compartido, documento ya creado, error de almacenamiento del enrollment). Borrarlo permite empezar de cero.
- **Solución estándar:** confirmar el `IDP`/account_id, eliminar el enrollment, avisar que ya puede iniciar un proceso nuevo.
  > _«Listo, el enrollment ha sido exitosamente eliminado.»_ / _«puedes avanzar con un nuevo proceso para estas personas, el registro fue eliminado.»_
- **Cuándo escalar a humano:** **NUNCA desenrolar sobre un caso con `risky_face`/fraude** — borraría la evidencia y el bloqueo. Requiere criterio humano: si hay cualquier señal de fraude, deriva a revisión manual antifraude en lugar de desenrolar. Si el desenrolamiento no resuelve y persiste un error de plataforma → **SUP-**.

### 7. Proceso "pegado" / "validando" / biometría se queda cargando
- **Síntoma (cliente):** _«se queda congelado»_ · _«nos están reportando falla en el proceso de biometría, se queda cargando y no le permite continuar»_ · _«¿por qué no es posible abrir este proceso?»_.
- **Diagnóstico:** dos familias de causa: (a) **espera de una base externa / collector** — p.ej. _«La base de datos del gobierno no está disponible»_ (Registraduría/RNEC, base de PPT); (b) **incidente de plataforma** en la etapa de evaluación de riesgo.
- **Solución estándar:** consultar el proceso; si la base está caída/intermitente, explicarlo en lenguaje claro y dar expectativa; **reintentar solo cuando la fuente se normalizó** (reintentar con la fuente caída consume intentos). Avisar proactivamente cuando se normalice.
  > _«este fallo se genera cuando no se logra acceder a dicha base por inestabilidad… no es posible corroborar que el documento se encuentre registrado.»_ · _«Por favor, intentar de nuevo con los usuarios. Ya hemos logrado normalizar el proceso de validación de rostro.»_
- **Cuándo escalar a humano:** si el proceso no carga por error de plataforma (no por la base) o la caída excede el SLA → **SUP-** (radicado, SLA 1–3 / 1–5 días hábiles, seguimiento proactivo). Referencia cruzada: ver playbook de **collectors/fuentes externas**.

### 8. OTP del flujo de identidad no llega (o llega por SMS, no WhatsApp)
- **Síntoma (cliente):** _«al pedir el código se demora en llegar y al llegar se vence el tiempo»_ · _«no le llega el código al cliente»_.
- **Diagnóstico:** el OTP del flujo de identidad/firma depende del **operador móvil y la señal** del usuario. Por SMS se pierde trazabilidad (proveedor Twilio); por WhatsApp sí hay seguimiento. El código expira; cada generación consume un valor que no se reutiliza.
- **Solución estándar:** usar el **fallback a WhatsApp o llamada** que el flujo habilita tras un envío fallido.
  > _«si no le llega por SMS intente usar el fallback de WhatsApp por favor.»_ · _«este flujo tiene habilitada la opción de cambiar el canal de envío de la OTP… luego de reportar que el primer envío no se hizo, me permite cambiar a WhatsApp.»_
- **Cuándo escalar a humano:** si falla de forma **masiva** para varios usuarios de una misma zona/operador → recopilar IDs y escalar a **SUP-**.

### 9. Usuario gasta intentos / cliente final llega por error al canal
- **Síntoma:** _«Ya intenté más de 15 veces y siempre me da error»_ — o un cliente reenvía/contesta mensajes viejos del bot y se reabre/consume flujo.
- **Diagnóstico:** demasiados reintentos seguidos activan un **bloqueo temporal por intentos superados** (medida de seguridad). Frecuentemente quien escribe es un **usuario final** del cliente, no la empresa cliente B2B.
- **Solución estándar:** **detectar la audiencia primero.** Si es usuario final: redirigirlo a la empresa con la que valida, este canal es solo soporte B2B. Si es el cliente: explicar el bloqueo por intentos, pedir esperar antes de reintentar y mejorar la captura, no quemar más intentos.
  > _«¿Eres un usuario que está realizando una validación junto a alguna empresa? De ser así, debes comunicarte directamente con ellos… Este canal corresponde al soporte para empresas de Truora.»_
- **Cuándo escalar a humano:** si el bloqueo por intentos no se libera tras la espera, o requiere reset → **SUP-** (o desenrolar si aplica y NO hay fraude).

---

## Límites de seguridad y PII (no negociables)

- **No compartir datos del usuario final con el cliente** (documentos, fotos, fechas, números). _«Por motivos de seguridad y protección de datos, no es posible compartir esa información, ya que corresponde al documento personal del usuario.»_
- **No desbloquear/desenrolar cuando hay evidencia de fraude.** _«Se evidencia que esta persona está intentando realizar el proceso con una foto de una foto de su documento. Por seguridad no se recomienda solicitar el desbloqueo.»_
- **`risky_face` y revisión manual son siempre humano** (antifraude). El agente recopila y encola; nunca decide levantar el bloqueo.
- **No exponer el detalle interno** de cómo se evalúa el riesgo, umbrales del modelo, ni cómo operan los collectors. La explicación al cliente se queda en "la fuente X presenta demoras" / "se detectó una inconsistencia".
- **OTP/valores consumidos no se reutilizan** ni se retoma el flujo en el mismo punto: se genera un proceso nuevo.
- **Detección de audiencia** (cliente B2B vs usuario final vs candidato) antes de responder: límites y respuestas distintas para cada uno.

## Tabla rápida de escalamiento

| Situación | Acción del L1 | Mesa |
| --- | --- | --- |
| `risky_face_detected` / foto de foto / fraude | Recopilar, encolar, NO desbloquear | Revisión manual antifraude (vía correo a CSM si el cliente reclama) |
| Activar Manual Review en la cuenta | Escalar | SUP- / CSM |
| OCR falla con buena foto / tipo de doc no soportado | Escalar con IDs | SUP- ingeniería |
| Proceso no carga por bug de plataforma | Radicar ticket, dar SLA | SUP- (1–3 / 1–5 días) |
| Base de gobierno caída/intermitente | Explicar, esperar, reintentar al normalizar | SUP- si excede SLA · ver playbook collectors |
| OTP falla masivo en una zona/operador | Recopilar IDs | SUP- |
| Desenrolar sin señales de fraude | Eliminar enrollment directamente | (resuelve el L1) |
| Documento de firma / ZapSign | Derivar | ZSUP- (otro producto) |
| Antecedentes / score / homonimia | Derivar | Background Checks (otro playbook) |
