# Playbook transversal — Collectors / Fuentes externas

> **Aplica a:** Checks (background checks) **y** Validación de identidad (DI).
> **Qué es:** NO es un producto; es un **patrón de diagnóstico de causa raíz**. Cuando el cliente reporta "el check no sale" o "la validación se quedó procesando", la causa más frecuente y confirmable es una **fuente externa (collector) caída, lenta, en mantenimiento o intermitente**.
> **Dimensión:** ~651 hilos tocan el tema (9.6% del corpus). En background checks, los collectors son la causa atribuida en **24%** de los hilos — la proporción más alta de cualquier bucket. (Fuente: `analisis.md` §2.1 y §2.2.)

---

## Qué es un collector y cómo lo vive el cliente

Los **collectors** son scrapers de Checks que recolectan data de fuentes públicas en la web: Registraduría, Procuraduría, Policía, SAT, IMSS, OFAC, Migración Colombia, bases de afiliados, bases para PPT, etc. Cuando una de esas fuentes **cambia, se cae, se pone lenta o bloquea el acceso**, el collector no responde — y el check queda demorado, fallido o "pendiente".

**El punto crítico de traducción:** el cliente **casi nunca** dice "la base está caída" (solo 6 hilos en todo el corpus lo dicen así). Describe el **síntoma**, no la causa:

- «la consulta sigue en proceso»
- «el check no sale»
- «la validación se quedó procesando»
- «están demoradas las verificaciones»

**La traducción síntoma → causa raíz la hace el agente.** Ese es el corazón de este playbook: ante un síntoma de demora/no-resultado en Checks o DI, la primera hipótesis a descartar es **fuente externa**, no falla de plataforma. El agente debe (1) consultar el estado del check/proceso y sus fuentes, (2) revisar el **Monitor de Estados** (herramienta interna que muestra qué fuentes están inestables y desde cuándo), (3) explicar la causa en lenguaje claro, (4) dar expectativa, (5) decidir esperar vs reintentar, y (6) escalar/avisar normalización según corresponda.

Regla de seguridad: **no se expone el detalle interno del collector** (cómo scrapea, umbrales, lambdas). La explicación al cliente se queda en "la fuente X está presentando demoras/intermitencias".

---

## Lenguaje del cliente (síntomas) vs lenguaje del agente (causa)

| Lo que dice el CLIENTE (síntoma, verbatim) | Lo que diagnostica el AGENTE (causa raíz, verbatim) |
| --- | --- |
| «no figura la consulta en el RNMC, pero si tiene novedad» | «la base Policía: Registro Nacional de Medidas Correctivas… quedó en estado skipped (omitida)… faltó la fecha de expedición de la cédula» |
| consulta de identidad demorada / "se quedó procesando" | «la demora está relacionada a la estabilidad de una de las bases para la validación de identidad, específicamente la que nos ayuda a confirmar la vigencia de un documento» |
| el check de PPT no sale / falla | «todas las consultas de antecedentes para PPT están quedando fallidas… una caída en la base de gobierno que… valida la identidad y el estado de los extranjeros» |
| verificación de empresa con score 0 / sin resultado | «las fuentes críticas… —DIAN y RUES— presentaron error al momento de la consulta… la DIAN informó oficialmente que… podrían presentar intermitencias debido a mantenimientos» |
| validación de venezolano con PPT da error | «la base "Inscripción al Estatuto Temporal de Protección para Venezolanos" se encuentra en mantenimiento… al tratarse de una base pública, su disponibilidad depende directamente de la entidad gubernamental» |
| check con bases "en rojo" / error | «al momento de ejecutar esta consulta, dichas fuentes se encontraban inestables o no disponibles… Revisando nuestro monitor de estados…» |

---

## Fuentes nombradas (citadas por los agentes)

Lista real de fuentes que los agentes nombran al atribuir la causa (conteo de hilos en `analisis.md` §2.1):

| Fuente | Hilos | Ejemplo verbatim |
| --- | --- | --- |
| **Registraduría Nacional (RNEC)** (CO) | 122 | «la base de la Registraduría Nacional del Estado Civil (RNEC) está presentando intermitencias. Debido a esta situación, las validaciones generan este motivo de rechazo» |
| **"Bases de gobierno"** (genérico) | 45 | «la base de gobierno está tardando más de lo normal en confirmarnos la vigencia del documento» |
| **OFAC / listas restrictivas / Interpol** | 26 | «Office of Foreign Assets Control - OFAC… status: completed» (parte del dataset international_background) |
| **Procuraduría** (CO) | 24 | «Lugar de votación, Procuraduría, Instituto Nacional Penitenciario… presentaron inestabilidad entre las 3:00 y 4:00 p. m.» |
| **Policía Nacional / RNMC** (CO) | 14 / 6 | «la base de la Policía – Registro Nacional de Medidas Correctivas ha presentado inestabilidad el día de hoy desde la 1:00 p. m.» |
| **SAT** (MX) | 13 | (fuente fiscal mexicana — consultas tributarias) |
| **Rama Judicial / TYBA / Judicatura** (CO) | 13 | «si consultamos en Rama Judicial no encontramos ningún proceso… no todas las fuentes permiten la consulta por ID» |
| **IMSS** (MX) | 11 | «realizamos la consulta a la base del Instituto Mexicano del Seguro Social - IMSS… se presentaron intermitencias, ya que la base se encontraba en mantenimiento» |
| **Contraloría** (CO) | 3 | (Boletín de Deudores Morosos del Estado — BDME) |
| **Migración Colombia** (Cédula de Extranjería, PPT) | — | «se valida contra Migración Colombia verificando que el documento esté registrado con estado aprobado o impreso» |
| **Afiliados del régimen contributivo y subsidiado** | — | «la fuente que ha presentado mayor nivel de intermitencias e inconsistencias en los últimos días» |
| **Inscripción al Estatuto Temporal de Protección para Venezolanos** (PPT) | — | «se encuentra en mantenimiento… caídas totales reconocidas» |
| **DIAN / RUES / RUNT / RUT** (CO empresas) | — | «las fuentes críticas… —DIAN y RUES— presentaron error» |
| **TransUnion / vigencia de documento** (CL) | — | «una inestabilidad en las bases de información de identidad en Chile (TransUnion y la consulta de vigencia del documento de identidad)» |
| **Datacrédito / Equifax** (burós, costo extra) | — | «información financiera proveniente de burós de crédito como Datacrédito o Equifax» |

---

## Manejo escalonado (el playbook)

El patrón confirmado en los hilos es: **esperar → reintentar → escalar → avisar normalización**. Distribución del manejo en los casos confirmados: pedir espera/paciencia 79%, escalar a ingeniería 53%, recomendar reintento 51%, confirmar normalización proactivamente 32%.

### Paso 1 — ESPERAR (cuando la fuente está caída/lenta AHORA)

**Cuándo:** la fuente sigue inestable o caída en este momento. Reintentar ahora solo consume intentos del usuario en vano.

> «Jose, la demora está relacionada a la estabilidad de una de las bases para la validación de identidad, específicamente la que nos ayuda a confirmar la vigencia de un documento. La base para este proceso en particular se está tardando más de lo normal en darnos el resultado.»

> «una de las bases de datos para la validación de la vigencia del documento está presentando una inestabilidad momentánea y está tardando más de lo normal. **Te recomiendo esperar un poco más.**»

> «Dentro del funcionamiento de los checks, es normal que algunas fuentes respondan con demora; el sistema realiza reintentos cuando un envío falla.» *(normaliza expectativa; el sistema ya reintenta solo)*

### Paso 2 — REINTENTAR (solo cuando la fuente YA se normalizó)

> ⚠️ **REGLA CRÍTICA — esperar vs reintentar.** No mezclar. Si la fuente está caída, **esperar** (reintentar consume intentos del usuario sin resultado). Reintentar **solo cuando la fuente ya se normalizó / está estable de nuevo**. El mejor ejemplo de aplicación correcta de la regla, en un mismo mensaje, distinguiendo fuente-por-fuente:

> «Brayan… las bases de Lugar de votación, Procuraduría, Instituto Nacional Penitenciario… presentaron inestabilidad entre las 3:00 y 4:00 p. m. … sin embargo, a la fecha se encuentran operando de manera estable. Por lo que **la recomendación es realizar de nuevo la consulta, sabiendo que estas fuentes ya están estables de nuevo.** Por otro lado, la base de Afiliados del régimen contributivo y subsidiado ha presentado fallas severas desde el día de ayer y, a esta hora, continúa inoperante.» *(misma respuesta: reintentar las estables, esperar/escalar la caída)*

> «Cuando esto pasa la recomendación es intentar realizar una nueva consulta **más tarde o el día de mañana**.» *(diferir el reintento, no reintentar en el acto)*

Variante con mitigación de cobertura (añadir input para apoyarse en otras fuentes):

> «te recomendamos incluir el campo "issue_date"… Al agregar este campo, el sistema podrá apoyarse en otras fuentes de información disponibles para este tipo de documento y así completar la validación de manera exitosa.»

### Paso 3 — ESCALAR a ingeniería (SUP-)

**Cuándo:** caída masiva, intermitencia prolongada/recurrente, o que excede el SLA — o cuando hay que descartar si es falla propia vs de la fuente.

> «Estamos revisando con el equipo una caída en la base de gobierno que es la que nos permite validar la identidad y el estado de los extranjeros con este tipo de documento. **En este momento todas las consultas de antecedentes para PPT están quedando fallidas.** Estamos descartando que no sea una falla en nuestro servicio o si es una inestabilidad propia de la base.»

> «la base "Afiliados del régimen contributivo y subsidiado" se encuentra **en revisión por parte de nuestro equipo técnico**, ya que es la fuente que ha presentado mayor nivel de intermitencias e inconsistencias en los últimos días… Tan pronto la base sea normalizada, el estado se actualizará automáticamente y podrás evidenciar la disponibilidad en nuestro **Monitor de Estados**.»

> «Te comparto el ticket interno del requerimiento escalado para que le hagamos seguimiento: **SUP-6629**. Espero darte un avance o respuesta dentro de los siguientes **1 a 2 días hábiles**.» *(escalamiento con ticket + SLA explícito)*

### Paso 4 — AVISAR NORMALIZACIÓN (proactivo)

**Cuándo:** la fuente vuelve a operar. Cerrar el loop sin que el cliente tenga que volver a preguntar.

> «lo estamos monitoreando y vemos que ya se está normalizando. Las consultas están arrojando el resultado en los tiempos esperados.»

> «Te escribo para compartir la novedad… Tras realizar un monitoreo constante… hemos observado una mejora sostenida en el servicio… durante las últimas 15 horas, el servicio ha estado funcionando correctamente: se registra el 100% de las consultas sin errores… Te agradecemos mucho la paciencia durante este proceso.»

> «El equipo nos confirma que se ha normalizado el proceso de validación de identidad.»

---

## Cuándo escalar

Escalar a **SUP-** (ingeniería Truora) cuando:

1. **Caída masiva / total** de una fuente — todas las consultas de un tipo quedan fallidas. Ej. PPT: «todas las consultas de antecedentes para PPT están quedando fallidas» → SUP-.
2. **Intermitencia prolongada o recurrente** — la fuente lleva días/semanas degradada. Ej. Boletín de Deudores Morosos del Estado: «ha presentado inoperatividad durante las últimas semanas; este caso ya se encuentra escalado a nuestro equipo de ingenieros».
3. **Hay que descartar falla propia vs de la fuente** — «Estamos descartando que no sea una falla en nuestro servicio o si es una inestabilidad propia de la base».
4. **El caso excede el SLA** o el modelo rechaza pese a que la base devuelve vigente — «este caso debo escalarlo al equipo técnico… la base de gobierno el documento sí está vigente, pero aun así el modelo lo rechazó. Se debe revisar el detalle en logs».

Al escalar: **compartir el número de ticket SUP-** y dar **SLA explícito** («1 a 2» / «1 a 3» / «1 a 5 días hábiles»), y dar **seguimiento proactivo**. Luego, **avisar la normalización** apenas la fuente se estabilice (paso 4) — no esperar a que el cliente vuelva.

> ❗ **NO confundir collector caído con error del cliente.** Antes de culpar a la fuente, verificar que el síntoma no sea por **inputs incompletos** (causa muy frecuente de `skipped`/`not_found`). Ej.: bases como RNEC se omiten por falta de **fecha de expedición de la cédula**; consultas solo por ID omiten fuentes que no soportan búsqueda por ID. En esos casos la acción es corregir el payload, no esperar ni escalar.

---

## Citas representativas verbatim (corpus real)

- **Plantilla espera (la más usada):** «la base de gobierno está tardando más de lo normal en confirmarnos la vigencia del documento. **Te recomiendo esperar un poco más o iniciar de nuevo la validación.**»
- **Inestabilidad regional (Chile) + bypass:** «hemos identificado una inestabilidad en las bases de información de identidad en Chile (TransUnion y la consulta de vigencia del documento de identidad). Por este motivo, se ha activado el bypass temporal y normalizaremos el servicio tan pronto como las bases se encuentren estables nuevamente.»
- **IMSS (MX) en mantenimiento:** «realizamos la consulta a la base del Instituto Mexicano del Seguro Social - IMSS y el correo fue enviado debido a que se presentaron intermitencias, ya que la base se encontraba en mantenimiento.»
- **PPT venezolano en mantenimiento + mitigación:** «la base "Inscripción al Estatuto Temporal de Protección para Venezolanos" se encuentra en mantenimiento. Debido a esto, pueden presentarse errores… al tratarse de una base pública, su disponibilidad depende directamente de la entidad gubernamental y puede presentar intermitencias.»
- **Empresas (DIAN/RUES) — afectación oficial externa:** «la DIAN informó oficialmente que entre agosto y octubre sus consultas automatizadas podrían presentar intermitencias debido a mantenimientos… los fallos observados no corresponden a un error interno de Truora, sino a una afectación temporal del servicio público.»
- **Multi-fuente con criterio mixto (esperar/reintentar/escalar):** «estas 3 fuentes… se han mostrado inestables. Cuando esto pasa la recomendación es intentar realizar una nueva consulta más tarde o el día de mañana. Las consultas a las bases [X, Y] fueron escaladas al equipo de ingenieros… Te comparto el ticket… SUP-6629.»
- **Normalización proactiva con métrica:** «durante las últimas 15 horas, el servicio ha estado funcionando correctamente: se registra el 100% de las consultas sin errores.»

---

### Resumen operativo para el agente L1

1. Síntoma de demora/no-resultado en Checks o DI → **primera hipótesis: fuente externa**.
2. Consultar estado del check/proceso por ID + **Monitor de Estados** (qué fuente, desde cuándo).
3. Descartar **input incompleto** (fecha de expedición, consulta por ID vs nombre) antes de culpar a la fuente.
4. **Fuente caída ahora → ESPERAR** (no reintentar; consume intentos en vano).
5. **Fuente ya normalizada → REINTENTAR** (o diferir a "más tarde / mañana").
6. **Caída masiva / prolongada / excede SLA → ESCALAR a SUP-**, compartir ticket + SLA.
7. **Avisar la normalización proactivamente** apenas la fuente se estabilice.
8. Nunca exponer el detalle interno del collector; explicar "la fuente X presenta demoras/intermitencias".
