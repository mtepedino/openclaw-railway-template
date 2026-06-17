# Playbook — Firma Electrónica (Truora Sign / ZapSign)

> Para agente L1. Construido sobre conversaciones reales de soporte (HubSpot, ago-2025 → may-2026). Citas verbatim entre comillas.

## Qué es este producto y qué NO es

La **firma electrónica** permite que una persona firme un documento con validez legal. **NO es** validación de identidad (TruFace/biometría/OCR), **NO es** check de antecedentes (`CHK...`, score, listas), **NO es** WhatsApp/engagement (plantillas, WABA, campañas). Si un caso es de esos productos, no pertenece a este playbook.

⚠️ Cuidado con el solape: la firma suele venir **al final de un flujo de Identidad Digital (DI)** — el usuario valida documento + rostro y luego firma. Que el síntoma aparezca "en el momento de firmar" no significa automáticamente que sea un problema de firma; puede ser una validación previa que falló (rostro no detectado, base de gobierno demorada, etc.). Diagnostica la etapa real.

### Distinción crítica: Truora Sign vs ZapSign

| | **Truora Sign** (firma nativa en flujo DI) | **ZapSign** (plataforma hermana) |
|---|---|---|
| Qué es | Firma dentro del flujo de Identidad Digital: OTP, firma en el chatbot, link generado tras la validación | Plataforma independiente de firma electrónica con su propio portal (`app.zapsign.co`), plantillas, sobres y soporte propio |
| Identificadores | `IDP...` (proceso), `IPF...` (flujo), teléfono del usuario final | ID numérico de documento, links `app.zapsign.co/...`, `zapsign.s3.amazonaws.com/...` |
| ¿Alcance del agente? | **SÍ** | **NO** → se deriva a la mesa de ZapSign |
| Mesa de escalamiento | `SUP-` (ingeniería Truora) | `ZSUP-` (ZapSign) |

### Flujo de TRIAGE (lo primero, siempre)

Más de la mitad de los casos llegan como "firma" sin nombrar plataforma. **Antes de diagnosticar o derivar, determina dónde está el documento.** Pregunta estándar del equipo:

> «¿Podrías indicarnos si tu consulta está relacionada con: Validación Digital, WhatsApp o Firma Electrónica? … Escribe a detalle el inconveniente.»

Señales para clasificar:
- Menciona `IDP...`/`IPF...`, "el flujo", "el chatbot", "el link de validación de identidad" → **Truora Sign** (tú lo atiendes).
- Menciona `app.zapsign.co`, "plantilla", "sobre", "el panel", links de zapsign → **ZapSign** (derivas a su mesa).
- Caso mixto (DI de Truora genera el documento vía integración con ZapSign) → puede requerir ambos; abre `SUP-` y coordina.

Cuando es ZapSign puro, el bot/agente deriva al canal propio de ZapSign:

> «Para soporte de ZapSign, puedes comunicarte a través de WhatsApp en [este enlace] … o por correo electrónico en support@zapsign.com.br.»

## Nota sobre el HANDOVER (firma saliendo de Truora)

La firma electrónica **deja de ser parte de Truora** (transición en curso). Aun así, el inbox de Truora seguirá recibiendo ~200 hilos/mes de firma por inercia. Para el agente L1 esto significa: la firma **ZapSign** se deriva a su mesa (`ZSUP-`, ~18% de los hilos de firma escalan, el triple del promedio); la firma del **flujo DI de Truora** (~13%) NO se va con el handover y sigue siendo alcance del agente. El triage es obligatorio porque define quién es el dueño del caso. Los problemas estructurales conocidos (abajo) se heredan con el handover.

---

## Casos

### TRIAGE — "Tengo un problema con la firma" (plataforma no especificada)
- **Síntoma (cliente):** «tenemos una novedad con la firma del documento» / «Necesito soporte … No se como hacer que dos personas firmen el mismo documento»
- **Diagnóstico:** El cliente no distingue marcas. No se puede diagnosticar ni derivar sin saber la plataforma.
- **Solución estándar:** Pedir plataforma + detalle + identificador antes de actuar. Si es ZapSign puro y es duda de uso/configuración, derivar al canal propio de ZapSign.
  > «¿Podrías indicarnos si tu consulta está relacionada con: Validación Digital, WhatsApp o Firma Electrónica? … ¿La novedad que estas presentando con cuantos usuarios te esta sucediendo?»
- **Cuándo escalar a humano:** Si tras el triage es ZapSign → **ZSUP- / canal ZapSign** (support@zapsign.com.br). Si es flujo DI Truora → lo resuelve el agente o `SUP-`.

### Link / OTP de firma vencido o consumido
- **Síntoma (cliente):** «no le llega el link» / «el usuario se demoró en firmar» / el proceso quedó "pegado" y no continúa.
- **Diagnóstico:** Los enlaces y OTP de firma tienen vida corta y **valores de un solo uso**: el JWT de la sesión expira ~2h, los links de archivo (`original_file`/`signed_file`) ~60 min. Si el usuario tarda o sale del flujo, el valor expira o se consume y no se reutiliza.
  > «falla porque el usuario se demoro en firmar el documento, por lo que la validación expiro a las 2 horas»
- **Solución estándar:** No se puede retomar el flujo en el mismo punto; se genera un **proceso nuevo**. El agente puede renovar/reenviar el link de firma cuando aplica.
  > «no es posible retomar el flujo en el mismo punto donde quedó la vez anterior, ya que cuando se trata del bloque de firma se generan valores que se consumen y no se pueden reutilizar. Esto garantiza que el proceso de firma sea seguro y trazable, por lo que siempre se requiere iniciar desde cero.»
  > «Le he renovado el link de firma a esta persona y le he enviado un recordatorio a su correo para que pueda avanzar de nuevo.»
  - Prevención (ZapSign): se puede configurar fecha límite de vigencia del link **por fecha, no por hora**.
- **Cuándo escalar a humano:** Normalmente no escala; es respuesta estándar. Escalar solo si la renovación del link falla técnicamente.

### Firma que no se posiciona / no se inserta en el documento
- **Síntoma (cliente):** «Las firmas en este documento no se visualizan en sus posiciones» / «en la plantilla se ubica bien, pero al momento de la firma sale corrida».
- **Diagnóstico:** Los campos de firma no quedaron posicionados al generar el documento. Es **deuda técnica estructural admitida** del flujo de suscripción (ej. ticket abierto ZSUP-459).
- **Solución estándar:** El agente intenta primero la corrección manual habitual (recargar la página tras corregir). Importante: si la firma **quedó posicionada pero no se visualiza**, hay reparación; si **nunca se posicionó**, no.
  > «he procedido a corregir el documento. Puedes por favor recargar la página para que puedas visualizarlo correctamente.»
  > «en este caso la firma no quedó posicionada, por lo que no fue posible efectuar dicho ajuste.»
  - Nota: posicionar visualmente la firma **no es obligatorio** para la validez legal — esta se sustenta en el registro de auditoría, identificación del firmante y certificado. Recomendar usar **plantillas** con las firmas pre-posicionadas para evitar el problema.
- **Cuándo escalar a humano:** Si la corrección manual no funciona → **ZSUP-** (ingeniería ZapSign).
  > «No me ha sido posible corregir el documento mediante el proceso que usualmente utilizamos para esta situación; por lo tanto, estoy escalando el caso a nuestro equipo técnico. El ticket de escalación es ZSUP-1321.»

### Múltiples firmantes / deudor-codeudor / "documento ya firmado"
- **Síntoma (cliente):** «tanto el deudor como el codeudor registraron el mismo número de celular … no le está permitiendo firmar al Deudor» / «ya sale que firmó … pero no tiene ningún proceso exitoso».
- **Diagnóstico:** Dos casos típicos: (a) deudor y codeudor comparten el mismo ID/cuenta y el rostro de uno se compara contra el documento del otro; (b) el usuario canceló el flujo pero el link de firma seguía vivo y firmó **fuera del flujo**, dejando el proceso en `declined`/`canceled` mientras el documento ya está firmado. Procesos posteriores fallan con `signer_already_signed_document`.
  > «aunque el usuario cancele el flujo … el link de firma queda disponible y este puede firmarlo por fuera del flujo … Los otros procesos posteriores fallan, porque ya el proceso encuentra que para esta persona hay un documento firmado, con motivo de fallo "signer_already_signed_document".»
- **Solución estándar:** Para (a), desenrolar el proceso de la persona afectada para que avance con uno nuevo; usar IDs/cuentas separadas por firmante. Para (b), explicar que el documento ya está firmado y es válido; prevenir limitando la vigencia del link.
  > «he eliminado el enrollment del proceso de [persona] para que pueda avanzar con uno nuevo … están compartiendo el mismo ID de cuenta y por eso su rostro se compara con la foto del documento de la otra persona.»
- **Cuándo escalar a humano:** Si el cliente necesita cambiar manualmente el estado de procesos (opción "Cambiar estado") o un comportamiento no estándar de la integración → **SUP-**.

### Superar 3 intentos
- **Síntoma (cliente):** «el cliente ha iniciado desde cero 3 veces y se queda en el mismo punto» / «no te entiendo cómo son los 3 intentos».
- **Diagnóstico:** Cada proceso tiene 3 reintentos (de foto/validación). Agotarlos **no rechaza el documento**: lo encola a revisión manual para extraer/corregir la data. El cliente a veces genera un proceso nuevo en lugar de agotar los reintentos del mismo proceso, por eso nunca llega a revisión manual. Los reintentos se ajustan en la integración del cliente.
  > «vemos en cada validación que se consume 1 solo reintento, quedando disponibles 2. Vemos que generan un nuevo proceso para el usuario sin agotar todos los 3 reintentos … por eso no avanza a la revisión manual.»
- **Solución estándar:** Indicar que agoten los 3 reintentos en el **mismo** proceso para llegar a revisión manual; o desactivar los reintentos en la cuenta para que avance de inmediato al equipo de MR.
  > «podrías pedirle que agote los reintentos de las fotos, enviándola 3 veces, para que llegue al equipo de revisión manual y ellos lo puedan extraer completo.»
- **Cuándo escalar a humano:** Si el origen es un tipo de documento que el OCR extrae mal (causa estructural) → **SUP-** (ej. SUP-5905 por CE). La habilitación de más intentos / ajuste de la integración es del cliente con apoyo técnico.

### Webhook al fallar / completar firma (evento doc_signed)
- **Síntoma (cliente):** «el webhook se está ejecutando 2 veces … en la segunda lanza error de duplicado».
- **Diagnóstico:** El sistema **reintenta el envío del webhook cuando una entrega falla** (p. ej. el endpoint del cliente rechaza la conexión: `Connection refused`, timeout). El reintento se hace **solo al endpoint que falló**, no a todos. El cliente percibe duplicados porque su servicio creó el registro en la primera entrega y la segunda choca.
  > «el sistema realiza reintentos de envíos cuando un envío falla.»
  > «[reenvía] Únicamente al [endpoint] que falló.»
- **Solución estándar:** Revisar logs de envío de webhooks, identificar el error de conexión del lado del cliente, recomendar idempotencia en su endpoint. Recordar que reprocesar un documento **re-dispara las notificaciones** hacia los firmantes (efecto secundario reconocido).
- **Cuándo escalar a humano:** Si los logs muestran un comportamiento de reintento anómalo del lado de Truora/ZapSign → **SUP-/ZSUP-** según plataforma.

### Validez legal / integridad — no eliminar ni alterar documentos firmados
- **Síntoma (cliente):** «me apoyan eliminando…» / pide modificar prefijos o datos de un documento ya firmado, o borrar uno solo de un sobre.
- **Diagnóstico:** Los documentos firmados son **inmutables** por validez legal. Con NOM-151 activada, no se pueden hacer ajustes una vez finalizada la firma. La validez se confirma por el **hash** del pie de página y el certificado.
  > «como la opción NOM-151 se encuentra activada en la cuenta, no es posible realizar ajustes una vez el proceso de firma ha finalizado … la validez del documento se confirma mediante el hash disponible en el pie de página.»
- **Solución estándar:** Explicar que no es posible eliminar un solo documento de un sobre firmado ni alterar datos post-firma. Para validar la constancia NOM-151 (México), guiar al certificado del documento firmado.
- **Cuándo escalar a humano:** No se escala para "lograr" la eliminación (no es posible). Si el cliente insiste por requerimiento legal, dejar constancia; sin acción sobre el documento.

### Límites de ZapSign (10MB, idioma portugués, lotes) → derivar
- **Síntoma (cliente):** archivo no carga / «aún hay textos en Portugués a pesar de configurar Español» / cargas masivas.
- **Diagnóstico:** Límites de **infraestructura ZapSign**, no ajustables por soporte Truora: tamaño máximo de archivo **10MB** (aplica UI y API); cuentas creadas en portugués muestran textos en pt; firma por lotes **máx. 250 documentos** (más se encolan en grupos).
- **Solución estándar:** Explicar el límite. Para 10MB, recomendar reducir/dividir el archivo. Para idioma, indicar dónde se origina; es tema de configuración de la cuenta ZapSign.
- **Cuándo escalar a humano:** Estos casos son **ZapSign** → derivar a su mesa **ZSUP- / support@zapsign.com.br**. Soporte no amplía el límite de 10MB.

---

## Reglas de seguridad / integridad legal (límites duros)

- No alterar ni eliminar documentos firmados (inmutabilidad / NOM-151 / hash de validez).
- Valores de firma (JWT/OTP/links) son de **un solo uso y con expiración** — no se reutilizan; siempre proceso nuevo.
- No compartir documentos ni datos personales de usuarios finales con el cliente sin justificación.
  > «Compárteme el link del documento y puedo solo verificar el estado del proceso de firma. No puedo realizar ninguna otra acción sobre el documento.»
- Reprocesar re-dispara notificaciones a firmantes (avisar antes).
- Agotar 3 intentos NO rechaza el documento: el proceso sigue en curso hacia revisión manual.

## Mesas de escalamiento

- **ZSUP-** → ingeniería ZapSign (firma ZapSign: posicionamiento, plantillas, 10MB, idioma, sobres).
- **SUP-** → ingeniería Truora (firma del flujo DI, integración Truora↔ZapSign, OCR, cambio de estado de procesos).
- Canal propio ZapSign para dudas de uso ZapSign: WhatsApp ZapSign / support@zapsign.com.br.
