# Agent Workspace Files

Este directorio contiene los archivos del workspace de agente que se copian automáticamente al contenedor.

## ¿Qué se copia?

Todo el contenido de este directorio se copia recursivamente al workspace del agente (`OPENCLAW_WORKSPACE_DIR`, default `/data/workspace`) **solo si el archivo no existe ya** en el destino.

## Archivos principales

- **`SOUL.md`** — Personalidad, tono y límites del agente
- **`AGENTS.md`** — Instrucciones operativas: flujo L1, triage, reglas de oro, seguridad
- **`IDENTITY.md`** — Identidad del agente: nombre, naturaleza, vibe, emoji
- **`MEMORY.md`** — Memoria durable: taxonomía de productos, reglas de oro, mapa de escalamiento
- **`TOOLS.md`** — Herramientas disponibles y cómo usarlas
- **`USER.md`** — Información sobre con quién habla el agente
- **`memory/`** — Playbooks detallados por producto:
  - `validacion-identidad.md`
  - `checks-antecedentes.md`
  - `firma-electronica.md`
  - `whatsapp-engagement.md`
  - `collectors-fuentes.md`
  - `otros-cuenta-facturacion.md`
  - `_voz-paola.md` — Voz/modelo de la analista

## Cómo funciona

1. Agregá o editá archivos en este directorio y commitealos al repo.
2. El `Dockerfile` copia todo el directorio `souls/` a `/app/souls` en la imagen.
3. El `entrypoint.sh` copia recursivamente todo el contenido a `${OPENCLAW_WORKSPACE_DIR}` **solo si el archivo no existe ya**.

Esto permite que Railway deployments traigan archivos por default, pero el usuario pueda modificarlos en el workspace persistente sin que un redeploy los pise.
