# Playbook transversal — Cuenta / Facturación / Comercial / API

> Conocimiento para el agente L1, de conversaciones reales de soporte Truora (HubSpot, ago-2025 → may-2026). Cubre los temas que **no** son producto core (identidad/check/firma/WhatsApp) pero que llegan mucho al L1. Bot de triage: Truself (`L-83860333`). Mesas: **FIN-** (financiero), **SUP-** (ingeniería), **comercial**.

## Qué cubre este playbook y qué NO

**Cubre:**
- **Cuenta y usuarios:** crear/invitar usuarios, roles, tipos de cuenta, recuperación de acceso/contraseña, carga masiva de miembros, SSO/SAML.
- **Facturación y pagos:** facturas, cambio de razón social/correo, cambio de tarjeta, recargas, cobros inesperados, cancelación/reembolso → siempre **FIN-**.
- **Comercial:** precios, planes, renovación, plan vencido, cobertura por país, demos → **comercial** (representante/ventas).
- **API/integración:** errores 401/403/404/500, token/API Key inválido, webhooks, costo de la API, documentación dev.

**NO cubre** (va a los playbooks de producto core): validación de identidad, checks/antecedentes, firma del flujo DI, WhatsApp/WABA, desbloqueos `risky_face_detected`, fuentes/collectors caídos. Si el hilo es puramente de eso, derivar al playbook correspondiente.

## Límites duros (evidenciados, no negociables)

- **No revertir cargos ya consumidos.** El agente no edita facturas emitidas ni devuelve dinero: _«Referente a la factura que ya ha sido emitida no podemos editarla, sin embargo, podríamos generar el cambio para las siguientes facturas.»_
- **Cancelaciones, reembolsos, cambios de facturación y cambios de método de pago → FIN-.** El agente abre el radicado y comunica SLA (típico 1-5 días hábiles, a veces 2-3), pero financiero ejecuta.
- **Precios, planes nuevos, cobertura, demos → comercial.** El agente canaliza con datos, no cotiza por su cuenta.
- **No dar información de otras cuentas** ni datos personales de usuarios finales.
- **Truora no genera cuentas genéricas:** todo usuario lleva correo + nombre + celular + rol.

---

## Cuenta / Usuarios

### Crear / invitar un usuario nuevo (regla de oro: nada de cuentas genéricas)
- **Síntoma:** _«Si mira quiero crear un usuario en truora para un asesor nuevo»_ / _«Pero me dice que no tengo permisos»_.
- **Diagnóstico:** el cliente quiere agregar a un miembro. A veces no tiene rol de administrador (de ahí el "no tengo permisos"); en otros casos pide una "cuenta general" por área, sin correo individual.
- **Solución estándar:** pedir los 4 datos obligatorios del miembro y crearlo (o guiar al admin). La regla dura: _«si lo que desean es una cuenta genérica no es posible. Truora no genera cuentas genéricas, siempre se debe asignar un correo: nombre, celular y asignarle un rol.»_ Un correo de área (ej. `recursoshumanos@empresa.com`) sí sirve si se trata como usuario normal con su rol. No requiere escalamiento.

### Tipos de cuenta: ¿personal o empresarial?
- **Síntoma:** _«cuando se crea un usuario en account.truora.com existe algo como business account»_ / _«si puedo crear una cuenta general que no esté asociado a un correo individual»_.
- **Diagnóstico:** confusión sobre si hay categorías separadas de cuenta.
- **Solución estándar:** _«cuando se crea una cuenta en account.truora.com, no existe una categoría separada como "business account". La cuenta creada ya funciona como cuenta empresarial.»_ Todas las cuentas Truora son corporativas; es el cliente (admin) quien decide qué dominios/usuarios tienen acceso. (En firma electrónica/ZapSign sí existen planes personales, pero es otra plataforma.)
- **Escalar/derivar:** no aplica.

### Carga masiva de miembros (Importar vs Actualizar)
- **Síntoma:** _«no puedo cargar masivamente unos agentes»_ / _«Ayer hice dos cargas y salen error»_.
- **Diagnóstico:** confusión entre "Importar Miembros" (crear nuevos) y "Actualizar miembros" (modificar existentes); o formato incorrecto del archivo.
- **Solución estándar:** _«por los errores que veo, me temo que usaste la opción de "Actualizar miembros" en vez de "Importar Miembros".»_ Para actualizar se necesita centro de facturación + código de país y que los usuarios ya existan; para importar, _«El único dato obligatorio es el correo, y el rol: Que debe ser tal cual como lo tienes creado en la cuenta.»_ Adjuntar el template descargable. Si la plataforma falla pese a formato correcto → SUP-.

### Recuperación de acceso / contraseña
- **Síntoma:** _«no le llega el correo para cambio de contraseña [correo del usuario]»_.
- **Diagnóstico:** el correo de restablecimiento se envía OK desde Truora pero no llega — casi siempre bloqueo del lado del cliente (filtro corporativo/TI, spam).
- **Solución estándar:** escalonar: (1) confirmar que el envío se registró exitoso; (2) revisar spam/otras bandejas; (3) pedir a TI del cliente que verifique bloqueos a correos de Truora; (4) si nada, recrear el usuario para forzar nuevo envío. Cita: _«seria importante revisar con su equipo de TI si este correo tiene algún bloqueo para recibir correos de Truora.»_ **No** entregar contraseñas genéricas.
- **Escalar/derivar:** si tras recrear sigue sin llegar → equipo interno reenvía el restablecimiento; si persiste, SUP-.

### SSO / SAML (Google Workspace)
- **Síntoma:** _«quiero saber si Truora tiene SSO»_ / _«es posible integrarlo con SAML»_.
- **Diagnóstico:** cliente corporativo quiere login federado.
- **Solución estándar:** Truora soporta SSO con Google Workspace; guía: `https://dev.truora.com/guides/sso_google/`. SAML también es compatible pero **requiere acompañamiento de ingeniería** (generar ACS URL / Entity ID, intercambiar metadata del IdP).
- **Escalar/derivar:** SAML → **SUP-** (ej. SUP-6201). Coordinar config y ventana de pruebas con el cliente; no cambiar la config en producción sin avisarle.

---

## Facturación (todo cambio de dinero/facturación → FIN-)

### Cambio de razón social / nombre / correo de la factura
- **Síntoma:** _«ajustar un tema con mis facturas»_ / _«como hago para que la factura quede a nombre de la empresa»_ / _«me ayudas a ajustar el correo a que debe llegar la factura».
- **Diagnóstico:** dato de facturación incorrecto a futuro. La factura ya emitida **no** se edita.
- **Solución estándar:** _«Referente a la factura que ya ha sido emitida no podemos editarla, sin embargo, podríamos generar el cambio para las siguientes facturas.»_ Pedir identificación fiscal + documento soporte y escalar a financiero. (El cambio de correo de envío sí se gestiona relativamente rápido.)
- **Escalar/derivar:** **FIN-** (ej. FIN-765), SLA 2-3 días hábiles; confirmar al cliente cuando financiero notifique.

### Cambio de método de pago / tarjeta
- **Síntoma:** _«necesito cambiar la tarjeta a la que se hacen los cargos»_ / _«confirmar el cambio de tarjeta para los pagos».
- **Diagnóstico:** el cambio **no es automático ni inmediato**.
- **Solución estándar:** _«El cambio consiste en modificar la forma de pago actual, cancelando la suscripción a la cuenta actual, por lo que les llegará la factura al correo para pago manual. En ese proceso de pago podrán cambiar a la tarjeta o cuenta que deseen.»_ Es decir: se espera la siguiente factura, llega al correo, y al pagarla manualmente se inscribe la nueva tarjeta.
- **Escalar/derivar:** **FIN-** (ej. FIN-826). SLA 1-5 días hábiles.

### Recarga de créditos / saldo
- **Síntoma:** _«Requiero realizar una recarga de créditos.»_
- **Diagnóstico:** operación de saldo/créditos del plan.
- **Solución estándar:** el agente no procesa la recarga directamente; canaliza con el equipo/representante. (En ZapSign, derivar al soporte/comercial de ZapSign por su canal.)
- **Escalar/derivar:** **comercial / FIN-** según corresponda; el bot no recarga.

### Cobro inesperado / "me cobraron de más" / cobro por separado
- **Síntoma:** _«ya cobraron sin dejar cambiar la tarjeta»_ / _«Me están haciendo el cobro por separado y es un tema»_.
- **Diagnóstico:** cargo no esperado. Con frecuencia es una factura ya programada/vencida que se descontó, o un cobro de un periodo previo. El agente investiga el historial pero **no revierte** nada consumido.
- **Solución estándar:** pedir que **relacione el cobro exacto** (fecha/monto/screenshot) y cruzar contra el historial de suscripciones. Ejemplo: _«el cobro que me relacionas es del 26 de oct, el cual está relacionado en el historial de cobros... compartido esta mañana.»_ Si hay error real (cobro duplicado/por separado), escalar.
- **Escalar/derivar:** **FIN-** para cualquier ajuste/devolución; el agente solo diagnostica y comunica.

### Comprobante / descargar factura
- **Síntoma:** _«acabo de hacer la renovación de un plan y necesito el comprobante»_.
- **Solución estándar:** _«Para que puedas visualizarla en la plataforma, accedes a través de Planes y Precios > Mis Planes > Gestionar Plan > Facturas.»_ El agente puede adjuntar la factura directamente.
- **Escalar/derivar:** no aplica.

---

## Comercial (precios / planes / cobertura / demo → equipo comercial)

### Quiero hablar con ventas / agendar demo
- **Síntoma:** _«como puedo hablar con ventas»_ / _«Hola 😄 Quiero hablar con el equipo de Truora 🚀».
- **Diagnóstico:** lead o cliente con consulta comercial; soporte no cotiza.
- **Solución estándar:** recolectar datos y canalizar. _«Este es el canal de soporte... el primer paso es recibir contacto de uno de nuestros representantes, para esto por favor confirma: Nombre completo, Email, Nombre de la empresa, Número de contacto con código de país, Producto(s) de interés. Con esta información... te canalizaremos con nuestro equipo comercial.»_ Para ZapSign se entrega un link directo de WhatsApp de ventas.
- **Escalar/derivar:** **comercial** (representante nombrado, ej. "Nicolás del área comercial", "Juan Pablo Díaz").

### Cambio de plan / upgrade / renovación
- **Síntoma:** _«tengo contratado un plan API de 80... si quiero cambiarme al de 200, cómo se actualiza? cuánto me cobran? pierdo los documentos que no use?»_
- **Diagnóstico:** duda de mecánica de planes. Para cambiar de plan **hay que cancelar el vigente primero** (no se renueva) y luego contratar el nuevo; no se pierden documentos/plantillas/acceso.
- **Solución estándar:** _«Para adquirir un nuevo plan debes cancelar este que tienes vigente. Esto hará que no se renueve pero no vas a perder tu acceso a la documentación, tampoco al resto de documentos de tu plan.»_ Lo ideal es cancelar **antes** de la renovación automática. Consumos extra del plan se cobran adicional: _«normalmente los planes por API te dejan consumir un poco más del número estipulado... Ya se generarían cargos adicionales por esos documentos adicionales.»_
- **Escalar/derivar:** dudas finas de precio/diferencias entre planes → comercial; cancelación de la suscripción puede requerir FIN-/comercial.

### Plan vencido / cancelado — reactivar
- **Síntoma:** _«como lo activo de vuelta?»_ / _«osea sería volver a cargar el plan que se está utilizando API80».
- **Diagnóstico:** suscripción cancelada o vencida; la tarjeta puede seguir registrada pero **no hay plan vigente**.
- **Solución estándar:** _«tu tarjeta registra asociada a tu cuenta. Pero en este momento no tienes un plan vigente. Debes contratarlo de nuevo y ya quedaría la suscripción activa.»_ Advertir que la tarjeta debe tener saldo cada mes o fallarán los cobros automáticos.
- **Escalar/derivar:** el link de compra/reactivación lo suele enviar el **representante comercial**.

### Cobertura por país / tipos de documento
- **Síntoma:** _«esta persona es venezolana... después de escanear el pasaporte solo le deja la opción de país Colombia»_.
- **Diagnóstico:** límite de cobertura por país y tipo de documento, no un error.
- **Solución estándar:** explicar la matriz vigente: _«solo para Perú se pueden hacer validaciones de antecedentes con Pasaporte. Para Col, con CC, CE, DNI (Venezolanos), PPT (Venezolanos). Para... Venezuela, aún no está disponible.»_ Recomendar configurar el flujo con los países/documentos soportados. Ampliaciones de cobertura → comercial.

---

## API / Integración

### 401 Unauthorized — API Key en el header equivocado (Truora)
- **Síntoma:** _«estoy haciendo test en su api... Authorization: Bearer mitoken pero me da error 401 unauthorized».
- **Diagnóstico:** en la API de Truora la autenticación **no** es `Authorization: Bearer`, sino un header propio.
- **Solución estándar:** _«el token... debes colocarlo en los headers con el detalle `Truora-API-Key` y en el valor tu API Key.»_ La API Key se crea desde "Claves API" en la plataforma. Si la key es válida y sigue fallando → SUP-.

### 403 / "API token not found" — token mal generado o de ambiente equivocado (ZapSign)
- **Síntoma:** _«realizamos todas las pruebas en el sandbox y funcionaron, cuando cambio la url y el token para producción me devuelve error... el token no es válido»_ / `ZapSign API error [403]: API token not found`.
- **Diagnóstico:** se usó un token que no es el API Token (ej. de documento/plantilla/firmante), o el token no corresponde al ambiente (sandbox vs producción), o mal formato en el header.
- **Solución estándar:** _«es necesario usar exclusivamente el "Token de acceso / Ficha API"... desde: Configuración > Integraciones > API de ZapSign > Token de acceso.»_ Verificar `Authorization: Bearer TU_API_TOKEN` sin espacios/comillas, usar el token del ambiente correcto, y **no** incluir `sandbox: true` en el body (el ambiente lo define el token). Si el token es correcto y ya se regeneró pero persiste → **SUP-/técnico** (pedir status code y request completo, token oculto).

### 404 Not Found — token o `account_id` equivocado en la petición
- **Síntoma (ZapSign):** GET `/api/v1/docs/{token}` devuelve 404 `Não encontrado`.
- **Diagnóstico:** se usó el **token del firmante** en lugar del **token del documento**.
- **Solución estándar:** _«El 404 ocurre porque estás usando el token del firmante en vez del token del documento... El único token válido para consultar el estado y obtener el PDF firmado es el que recibes al crear el documento, en el campo "data.token".»_
- **Síntoma (Truora):** error 400/10400 `enrollment not found` al abrir el iframe. **Diagnóstico:** el `account_id` enviado no coincide con el del enrollment. _«deben asegurarse de enviar siempre el mismo account_id con el que se creó el enrollment original del usuario.»_
- **Escalar/derivar:** si el path/dato es correcto y la API sigue devolviendo 404 inexplicable → SUP-.

### Webhook no llega / llega duplicado / no se ejecutó
- **Síntoma:** _«tenemos un caso donde no corrió el webhook»_ / _«el webhook se está ejecutando 2 veces»_ / _«hay alguna intermitencia en el servicio de webhooks?»_.
- **Diagnóstico:** dos causas frecuentes. (1) **Intermitencia del servicio** de webhooks (lado Truora/ZapSign) — confirmable y se normaliza. (2) **El endpoint del cliente rechaza la conexión**: el sistema reintenta y eso produce envíos repetidos. _«el sistema realiza reintentos de envíos cuando un envío falla.»_ (ej. `Connection refused / Max retries exceeded`).
- **Solución estándar:** pedir IDs/horas exactas. Si fue intermitencia, confirmar normalización y pedir validar. Si el endpoint del cliente falla, mostrarle el error de conexión y aclarar que el reintento es solo al endpoint que falló: _«Únicamente al que falló.»_ Intermitencia/reproceso de webhooks perdidos → **SUP-/técnico** con rango horario.

### Campos del webhook/validación: qué es obligatorio
- **Síntoma:** _«el webhook no regresó la variable "expedition_place" y esto nos genera fallos».
- **Diagnóstico:** el cliente depende de un campo **opcional** que no siempre se extrae (p.ej. por calidad de foto), aunque el proceso sea exitoso.
- **Solución estándar:** _«la extracción del dato de lugar de expedición del documento no es obligatorio... a pesar de esto, el proceso fue exitoso.»_ Obligatorios para cédula CO: nombre y apellidos, número de documento, fecha de expedición, fecha de nacimiento, production data; el resto no afecta el resultado. No aplica salvo bug confirmado.

### ¿Usar la API tiene costo?
- **Síntoma:** _«usar la API tiene un costo adicional?»_
- **Diagnóstico:** duda común; depende del plan.
- **Solución estándar:** habitualmente **sin costo adicional**: _«No, la API no tiene un costo adicional 😊»_ y _«la utilización de la API en Truora se encuentra contemplada por defecto dentro del contrato.»_ API Key en Truora desde "Claves API" / en ZapSign desde Ajustes > Integraciones > API. **Excepción:** funcionalidades que consumen créditos sí cobran, p.ej. link de firma por WhatsApp: _«5 créditos por envío por WhatsApp y estos 5 créditos equivalen a $0,1 USD.»_ Pricing fino → comercial.

### Documentación para desarrolladores
- Truora: `https://dev.truora.com` (guías, ej. SSO). ZapSign: `https://docs.zapsign.com.br` (autenticación, documentos, webhooks, firmantes, plantillas). El bot Truself entrega estos enlaces en triage.

---

## Reglas operativas rápidas para el agente
- **Identificar audiencia primero:** cliente B2B (admin de la cuenta) vs usuario final vs lead comercial — cada uno tiene límites distintos.
- **Pedir el identificador** antes de diagnosticar: correo de la cuenta, ID de flujo/proceso, número de factura, status code, request completo (token oculto).
- **Comunicar SLA y dar el radicado** al escalar (FIN-xxx / SUP-xxxx) y hacer seguimiento proactivo.
- **Facturación/cancelación/reembolso → FIN-**, nunca prometer reversión de cargos consumidos. **Precios/cobertura/demo → comercial** con datos completos. **No exponer datos de otras cuentas** ni de usuarios finales.
