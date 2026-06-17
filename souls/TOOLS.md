---
summary: "Contratos de tools de negocio que Sofía espera (hoy PENDIENTES) + notas de entorno"
title: "TOOLS.md — Notas de tools locales"
read_when:
  - Cuando un caso requiera ejecutar una acción en sistemas de Truora
  - Para entender qué puedes hacer hoy vs. qué se escala a humano
---

# TOOLS.md — Notas locales

> **Importante:** este archivo NO controla qué tools existen (eso se configura en `openclaw.json`). Es la guía de tu entorno y el **contrato esperado** de las acciones de negocio.
>
> **Estado actual:** las tools de negocio de Truora **aún no están implementadas**. Mientras tanto, cualquier caso que requiera ejecutar una de estas acciones se **escala a un agente humano** (ver `AGENTS.md` § Escalamiento). Diagnostica y explica lo que puedas; para la ejecución, conecta con un humano.

## Contratos de tools esperados (PENDIENTE de implementar)

Cuando se construyan, estas son las acciones que el L1 humano hoy ejecuta y que deberás usar:

| Tool | Input | Output | Notas |
| --- | --- | --- | --- |
| `consultar_proceso` | `id` (`IDP…` / ID de cuenta / `CHK…`) | Estado del proceso de validación/firma/check + razón de fallo + fuentes pendientes | Base del diagnóstico. **PENDIENTE** |
| `estado_fuentes` | — | Salud de collectors/fuentes públicas (qué fuente, desde cuándo, si hay reintentos) | Habilita el playbook de collectors sin escalar. **PENDIENTE** |
| `estado_plataforma` | — | Afectaciones generales de plataforma | Distinguir caída propia vs. fuente externa vs. Meta. **PENDIENTE** |
| `cerrar_sesion_waba` | `telefono` o `session_id` | Confirmación de cierre | Operación rutinaria (ej. WOM). Confirmar intención antes. **PENDIENTE** |
| `reenviar_otp_o_link` | `id` | Confirmación / nuevo link | Recordar expiración (archivo ~60 min, JWT ~2h); los valores no se reutilizan. **PENDIENTE** |
| `reprocesar_documento` | `id` | Confirmación | Reprocesar puede re-disparar notificaciones (firma). **PENDIENTE** |
| `desenrolar` | `idp` / ID de cuenta | Confirmación | Requiere criterio humano. **NUNCA** sobre casos con fraude/`risky_face`. **PENDIENTE** |
| `encolar_revision_manual` | `caso` | Confirmación de encolado | Para `risky_face_detected`. La **decisión es siempre humana**; tú solo encolas. **PENDIENTE** |
| `crear_ticket` | `mesa` (SUP-/ZSUP-/FIN-), `caso` | Número de radicado + SLA | Comunica radicado y plazo al cliente. **PENDIENTE** |

## Notas de entorno

- **Canales:** `1007` = WhatsApp principal (91% del volumen), `1000` = chat web (~7.6%), `1002` = segunda línea WhatsApp (~1.2%).
- **Identificadores que verás:** `IDP…` (proceso de Identidad Digital — contiene varias validaciones), `VLD…` (una validación dentro del proceso), `IPF…` (flujo), `ENR…` (enrollment), `CHK…` (check), `CPG…` (campaña WhatsApp), `CHT…` (chat), `account_id`/`ACC…` (cuenta del cliente — **no se lo pidas al cliente**, derívalo por el nombre de la empresa), `SUP-####`/`ZSUP-####`/`FIN-###` (radicados). Recuerda: **un proceso `IDP` no es una validación `VLD`** (un proceso agrupa varias validaciones de distinto tipo). `consultar_proceso` aceptará `IDP…` o `VLD…`.
- **Documentación pública para clientes:** `https://dev.truora.com/docs/` (API reference).
- **Autenticación API:** Truora usa el header `Truora-API-Key`; ZapSign usa `Authorization: Bearer` (fuente frecuente de 401/403 — verifica plataforma).
- **Bot previo en el canal:** Truself (`L-83860333`) hace triage automático y transfiere; sus respuestas a veces confunden plataforma (responde como ZapSign). No tomes su salida como verdad de dominio.
- **Herramienta interna referida por el equipo:** "Monitor de Estados" muestra qué fuentes/collectors están inestables — equivalente humano de `estado_fuentes`.
