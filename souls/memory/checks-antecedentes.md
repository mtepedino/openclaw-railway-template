# PLAYBOOK — Checks / Background Checks (Antecedentes)

> Contexto para agente L1. Construido a partir de conversaciones reales de soporte (HubSpot). Marco de dominio en `analisis.md` (secciones 2.1 collectors/fuentes, 0 glosario). Identificadores de proceso: **`CHK...`** (consulta de antecedentes), `TCI...` (client_id). El bot de triage es `L-83860333` (Truself/Lucía); analistas humanos: Yeison `A-78924545`, Lina `A-83198633`, Paola `A-60656017`.

## Qué es este producto y qué NO es

Un **Check (antecedentes / background check)** es la consulta de una persona, empresa o vehículo contra **fuentes públicas y privadas** (Registraduría/RNEC, Procuraduría, Policía Nacional, Rama Judicial, RUNT, OFAC y otras listas restrictivas, SAT/IMSS en MX, etc.) para producir un **reporte con score de riesgo y resultados por categoría** (identidad, antecedentes legales/criminales, financieros, listas internacionales). El reporte se entrega en JSON vía API (`api.checks.truora.com`) y/o como PDF en el panel.

**Frontera de dominio — NO confundir.** Un Check **NO es**:

- **Validación de identidad** (facial/documento, TruFace, liveness, `risky_face_detected`, enrollment, IDP…). Aunque comparten fuentes (RNEC), un IDP/VLD/ENR/desbloqueo de rostro es producto de **Identidad Digital**, no un Check. Si el caso es un bloqueo de rostro, desenrolamiento o "validando selfie" → **fuera de este playbook**.
- **Firma electrónica** (Truora Sign / ZapSign, sobres, firmantes, "Erro para baixar o seu arquivo", links de firma) → **fuera**.
- **WhatsApp / Customer Engagement / WABA** (plantillas, campañas, sesiones pegadas) → **fuera**.

Señales de que SÍ es un Check: el cliente menciona "antecedentes", "background check", "consulta de listas", `CHK...`, `type=penal/identity/vehicle`, "score", "homonimia", "consulta por nombre vs ID", "la base no responde", reporte/informe de antecedentes.

> Nota de cobertura comercial: cuando se vende **vía ZapSign con créditos** (90 créditos por consulta de antecedentes legales de persona/empresa, 200 por historial crediticio; ~5 créditos = 0,1 USD), sigue siendo el producto de antecedentes y es alcance del agente para explicar el modelo; los **precios y la activación de bases premium se derivan a comercial**.

---

## Casos

### 1. "El check no sale" / consulta fallida o pendiente por fuente caída (collector)

- **Síntoma (verbatim):** _«evidencio el dia de hoy dos procesos fallido por motivo de rechazo "La base de datos del gobierno no está disponible"»_ — también _«queda indefinidamente en estado not_started con score: -1»_ y _«Al hacer esta consulta nos arroja error en muchas listas, ¿a qué obedece?»_
- **Diagnóstico:** Causa raíz #1 de Checks (24% de los hilos del bucket tienen atribución explícita a fuentes). El cliente vive como "demora/no sale" lo que es una **fuente externa intermitente o caída**: el collector (scraper) no obtiene respuesta de la entidad pública. Fuentes frecuentes: **RNEC/Registraduría** (la más recurrente, agravada en **periodo electoral** con bloqueo de consultas masivas), base de **PPT** (Estatuto Temporal de Protección para Venezolanos, ha tenido caídas/mantenimiento), Insolvencia, RUT, Superintendencia de Sociedades, incluso **OFAC** "en rojo".
- **Solución estándar:** (a) pedir el `CHK...`; (b) consultar estado del check y sus fuentes; (c) si una fuente está caída/intermitente, **explicarlo con plantilla y nombrar la fuente**; (d) dar expectativa y avisar proactivamente la normalización; (e) **recomendar reintento solo cuando la fuente ya se normalizó** (no antes: consume intentos). Dirigir al cliente al autoservicio cuando exista: _«Para revisar el estado actualizado de las bases de datos, puedes acceder a la sección **Monitor de Estados** dentro del módulo de Verificación de Antecedentes.»_
  - Cita verbatim (RNEC): _«Revisando los procesos y confirmando con nuestro equipo técnico, hemos identificado que en este momento la base de la Registraduría Nacional del Estado Civil (RNEC) está presentando intermitencias. Debido a esta situación, algunas validaciones pueden generar este motivo de rechazo… nos encontramos trabajando activamente para mitigar el impacto.»_
  - Cierre proactivo modelo: _«durante las últimas 15 horas, el servicio ha estado funcionando correctamente: se registra el 100% de las consultas sin errores.»_
- **Cuándo escalar a humano:** caída **masiva** o que supera el SLA, varios clientes afectados, o cuando hay que confirmar con ingeniería si la falla es propia vs de la entidad → **ticket `SUP-`** (ingeniería). Ej. real: `SUP-6773` por inestabilidad de RNEC en periodo electoral. Comunicar SLA "1 a 3 / 1 a 5 días hábiles" y dar seguimiento ("Tenemos progresos en la solicitud que nos escalaste 🤩").

### 2. Homonimia — consulta por nombre trae más hallazgos que por documento

- **Síntoma (verbatim):** _«quiero entender porque si hacemos el background check con el national ID, esta haciendo verificaciones por nombre? Salio una persona con procesos legales pero fue consultado por nombre en vez de id y casi se va para atrás porque no es así»_
- **Diagnóstico:** Cada fuente define **su propio método de búsqueda**. Algunas (Registraduría, Policía) solo responden por número de documento; las **judiciales/legales** (Consejo Superior de la Judicatura, procesos judiciales) publican por **nombre y apellidos**. Truora consulta por nombre en esas fuentes porque es la única vía. Eso introduce **riesgo de homonimia**: dos personas con el mismo nombre. Por eso el informe presenta **puntaje por ID y por nombre** (`by_id` / `by_name` en el JSON).
- **Solución estándar:** explicar la mecánica fuente-por-fuente y recomendar contrastar los hallazgos por nombre directamente con la fuente. **Truora no altera ni interpreta**: entrega lo que devuelve la fuente.
  - Cita verbatim: _«algunas fuentes responden únicamente por número de identificación (por ejemplo, la Registraduría Nacional o la Policía Nacional), mientras que otras, especialmente en el ámbito judicial y legal, registran y publican la información por nombre y apellidos… Cuando una fuente es consultada por nombre, existe el riesgo de homonimia, es decir, que personas distintas compartan nombres o apellidos similares… se recomienda siempre contrastar los registros que nos trae el informe directamente con las fuentes. Truora no altera ni interpreta la información: entrega exactamente los resultados que devuelven las fuentes consultadas.»_
- **Cuándo escalar a humano:** normalmente NO se escala; es explicación pedagógica L1. Escalar solo si el cliente reporta un **flujo automatizado** que guarda hallazgos por nombre sin revisión humana y pide cambio de comportamiento del producto → derivar a su **CSM/comercial** (mejora de producto).

### 3. Resultado `not_found` / consulta incompleta por inputs faltantes (fecha de expedición)

- **Síntoma (verbatim):** _«note que durante las pruebas, no salen antecedentes legales, cosa que del usuario de prueba de alejandra su ejecutiva si»_ — y _«tengo este caso, con dos consultas diferentes para la misma persona, y los resultados son diferentes»_
- **Diagnóstico:** La consulta se **completa** pero varias fuentes quedan en `skipped` / `not_found` porque faltó un **input obligatorio**, típicamente la **fecha de expedición del documento** (`document_issue_date`) para CC colombianas, o el documento se ingresó sin nombre/fecha de nacimiento. En el JSON aparece `"status": "skipped", "invalid_inputs": ["document_issue_date", …]`. También ocurre por **fecha de expedición mal digitada**: la RNEC responde "el número de documento no se encuentra o la fecha no corresponde". No es una falla del producto sino datos de entrada incompletos/erróneos.
- **Solución estándar:** revisar el `CHK...`, identificar qué bases quedaron skipped y por qué; pedir reenviar con el campo faltante. Para CC colombianas: **siempre enviar fecha de expedición**.
  - Cita verbatim: _«identificamos que la consulta fue realizada sin incluir la fecha de expedición del documento de identidad. Varias fuentes nacionales… requieren ese dato para poder ejecutarse correctamente; al no recibirlo, algunas de ellas no pudieron completar su consulta… Le recomendamos repetir las consultas, pero esta vez incluir la fecha de expedición del documento al momento de crear la consulta para garantizar que todas las fuentes disponibles se ejecuten correctamente.»_
- **Cuándo escalar a humano:** si los inputs **sí eran correctos** y aun así dos consultas con los mismos datos dan resultados distintos (inconsistencia real) → escalar a ingeniería. Ej. real: `SUP-7392` ("identificamos una inconsistencia en los resultados de antecedentes legales entre dos procesos ejecutados para los mismos inputs").

### 4. Interpretación del score y del estatus por base

- **Síntoma (verbatim):** _«Me puedes dar contexto de que significa esta validación»_ / _«no sé qué resultados me arroja… ¿Cuáles son esas fuentes?»_
- **Diagnóstico:** El cliente no sabe leer el reporte: qué es el score global, qué significa cada `status`/`result` y por qué un mensaje aparece tal cual.
- **Solución estándar:** explicar la estructura: **score global de riesgo (0 a 10, donde 10 = nivel de confianza alto)**, resultados por categoría (identidad, antecedentes legales/criminales, financieros, listas) y severidad por hallazgo; las anotaciones que devuelve directamente la base se transcriben sin interpretación.
  - Cita verbatim (estructura): _«El reporte… muestra un resumen con el score de riesgo y los datos principales… incluye los resultados por categoría (identidad, antecedentes legales, criminales, financieros, etc.) y las fuentes consultadas… Cada resultado se clasifica por severidad e impacta el puntaje global del check de 0 a 10, donde 10 representa un nivel de confianza alto.»_
  - Cita verbatim (anotación de base): _«esta anotación se genera cuando al consultar el documento la base retorna que o no está registrado o la fecha de expedición enviada no corresponde al número de documento, este ya es un mensaje que retorna directamente la base en cuestión.»_
- **Cuándo escalar a humano:** NO. Explicación L1 pura. Si piden el **detalle de fuentes específicas que componen un plan / qué bases trae su contrato** → derivar a **comercial** (las fuentes varían por cliente).

### 5. Cobertura: tipos de check, países y documentos soportados

- **Síntoma (verbatim):** _«esta persona es venezolana, y me dice que después de escanear el pasaporte no solo le deja la opción de país de colombia»_ / _«¿El identification_type ptp está soportado para checks tipo identity… en Colombia?»_
- **Diagnóstico:** El cliente intenta consultar un país o documento no habilitado en su flujo, o asume que pasaporte/RUT funcionan en cualquier país. La cobertura es **por país + tipo de documento**.
- **Solución estándar:** confirmar matriz de cobertura. Verbatim (cobertura): _«solo para el Perú se pueden hacer validaciones de antecedentes con Pasaporte. Para Col, con CC, CE, DNI (Venezolanos), PPT (Venezolanos). Para consultas… en Venezuela, aún no está disponible. Se pueden consultar antecedentes para ciudadanos venezolanos en Colombia pero con los documentos antes mencionados.»_ Para **PPT** el tipo de documento `ppt` SÍ está soportado; si la base de PPT está en mantenimiento, recomendar incluir `issue_date` para apoyarse en otras fuentes.
- **Cuándo escalar a humano:** si el cliente necesita **habilitar un país/base no contratada** → **comercial / CSM**. Si la consulta queda `not_started`/`score:-1` por base en mantenimiento con clientes bloqueados en producción → **`SUP-`** ingeniería.

### 6. API de Checks: crear vs consultar detalles del check

- **Síntoma (verbatim):** _«veo un parámetro que no aparece en el objeto que arroja la API»_ — el dato sí aparece en el PDF del panel pero no en el JSON.
- **Diagnóstico:** El cliente usa el endpoint de **creación** (`POST /v1/checks`) y espera ver ahí todos los campos. El detalle completo (que alimenta el PDF) está en **`GET /v1/checks/{check_id}/details`**. El PDF se construye con la misma información que la API; si "falta" un dato suele ser que se consulta el endpoint equivocado, un tipo de check distinto (p.ej. Conductor por cédula vs Vehículo por placa son `CHK` diferentes), o un parámetro mal armado en la consulta.
- **Solución estándar:** verificar qué endpoint usa; indicar `GET /v1/checks/{check_id}/details` para el detalle; confirmar que el `check_id` y el tipo de check correspondan al dato buscado. Referir docs: `https://dev.truora.com/docs/`.
  - Cita verbatim: _«el dato… no se encuentra disponible como un campo estándar en la respuesta JSON de la API… aunque es posible visualizarlo en los documentos o reportes generados… el PDF se construye directamente con base en la información que retorna la API, por lo que ambos deberían reflejar el mismo contenido… Para ver los detalles del check, utiliza GET /v1/checks/{check_id}/details.»_
- **Cuándo escalar a humano:** si tras usar `/details` con inputs correctos un campo documentado realmente no aparece → **`SUP-`** ingeniería para confirmar soporte del campo.

### 7. Reporte de consultas masivas / auditoría de checks fallidos

- **Síntoma (verbatim):** _«necesitaria la cantidad de llamadas que le realizamos a truora… con los codigos de retorno, para ver cuantas fallaron y el pq de esas mismas»_ / _«esta información la está solicitando auditoría»_
- **Diagnóstico:** El cliente pide un **agregado/reporte** de sus checks (payload enviado, respuesta devuelta, errores) por rango de fechas, normalmente para auditoría o para corregir su integración. Frecuentemente lo que cree "fallido" es en realidad `not_found`/`skipped` por inputs incompletos (ver caso 3).
- **Solución estándar:** pedir `CHK...` puntuales primero; entregar por consulta el payload y el JSON de salida explicando cada `status`. Aclarar que una consulta `completed` con `not_found` **no es un error**. Para extracciones grandes (todos los JSON desde una fecha), gestionar el tiempo: requiere trabajo manual y se entrega diferido.
- **Cuándo escalar a humano:** reportes masivos por rango de fechas o cruce con telemetría → **`SUP-`** ingeniería (ej. `SUP-6082`). Mejoras al detalle del informe (que la consulta masiva desglose el estado del documento por persona) → requerimiento de producto vía CSM/comercial.

### 8. Nombre mal concatenado en el reporte (la fuente lo trae así)

- **Síntoma (verbatim):** _«el cliente en registraduría tiene sus datos correctos, ya cual como figuran en la cédula»_ pero el reporte muestra el nombre duplicado/mal posicionado.
- **Diagnóstico:** El nombre llega **mal concatenado desde la fuente externa** (Registraduría/Certicámara/Procuraduría) en la consulta masiva, aunque la consulta individual en la fuente lo muestre bien. Truora reproduce lo que entrega la fuente.
- **Solución estándar:** explicar que el dato proviene de la fuente y que un parche en código podría dañar otros nombres válidos; recomendar que la persona valide directamente con la entidad.
  - Cita verbatim: _«el nombre que muestra el proceso es exactamente el que están enviando las fuentes externas consultadas… realizar un ajuste en el código podría generar efectos no deseados en otros usuarios… no contamos con una solución que garantice corregir este caso de forma segura y sin impacto general.»_
- **Cuándo escalar a humano:** ya escalado (`SUP-7056`); típicamente cierra como "no hay solución segura". Documentar y gestionar expectativa.

---

## Límites de seguridad / PII (evidenciados)

- **No compartir datos/documentos del usuario final con el cliente** cuando no corresponde: _«Por motivos de seguridad y protección de datos, no es posible compartir esa información, ya que corresponde al documento personal del usuario.»_
- **No exponer el detalle interno de los collectors** (cómo scrapean, umbrales): la explicación se queda en "la fuente X presenta demoras/intermitencias".
- **No prometer reprocesos ni alterar resultados** de la fuente: Truora entrega lo que la fuente devuelve; no interpreta ni modifica.
- **No realizar llamadas telefónicas**: la atención es por el canal de chat/correo; comercial se contacta por correo/WhatsApp designado.
- Los analistas comparten `CHK...`, cédulas y JSON en texto plano por el canal — el agente LLM debe **minimizar PII** y no volcar payloads completos cuando no es estrictamente necesario.

## Reglas operativas para el agente

1. Pedir el **`CHK...`** (o el input usado) antes de diagnosticar.
2. Ante "no sale / pendiente / fallida": **consultar estado del check y sus fuentes** → traducir síntoma a causa raíz (collector) → nombrar la fuente → dar expectativa → **reintentar solo si la fuente ya se normalizó**.
3. Distinguir `completed`+`not_found`/`skipped` (datos incompletos del cliente, caso 3) de una **caída de fuente** (caso 1) de una **inconsistencia real** (escalar).
4. **Mesas de escalamiento:** ingeniería = **`SUP-`** (caídas masivas, inconsistencias, soporte de campos API, reportes masivos); **comercial / CSM** (precios, planes, activar país/base nueva, base premium con más info, mejoras de producto). Nunca dejar la decisión antifraude (risky_face) aquí: eso es Identidad Digital, fuera de dominio.
5. Si el caso resulta ser identidad facial, firma o WhatsApp → **derivar al playbook correcto**, no resolver como Check.
