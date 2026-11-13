# Secrets

Este repo **no contiene secretos**. Los archivos reales con credenciales se generan
localmente y están ignorados por git (ver `.gitignore`).

## Variables requeridas

| Variable | Uso | Dónde obtenerla |
|---|---|---|
| `CONTEXT7_API_KEY` | Context7 MCP (OpenCode y Antigravity) | Dashboard de Context7 |
| `TESTSPRITE_API_KEY` | TestSprite MCP | Cuenta de TestSprite |
| `GITHUB_PAT` | GitHub MCP (OpenCode remote y Antigravity) | GitHub → Settings → Developer settings → Personal access tokens |
| `SUPERMEMORY_TOKEN` | Supermemory MCP (Antigravity) | Cuenta de Supermemory |
| `NOTION_TOKEN` | Notion MCP (Antigravity) | Notion → Integrations |
| `INVGATE_TOKEN` | InvGate `service-management` MCP (Antigravity) | InvGate |
| `OPENCODE_SERVICE_PASSWORD` | Password del servicio/web de OpenCode | Elige una o `opencode service set password` |

## Cómo proveerlas

Opción A — entorno de usuario (persistente, Windows):

```powershell
[Environment]::SetEnvironmentVariable('CONTEXT7_API_KEY', 'valor', 'User')
```

Reabrir la terminal después. Repetir por cada variable.

Opción B — solo para la sesión actual:

```powershell
$env:CONTEXT7_API_KEY = 'valor'
```

Opción C — gestor de contraseñas: inyectar con `$env:VAR = ...` antes de sincronizar.

No escribas valores en `.env`, `.env.local` ni en los archivos de ejemplo: están ignorados,
pero el objetivo es que nunca queden en disco dentro del repo.

## Cómo se consumen

- **OpenCode**: interpola `{env:VAR}` nativamente al cargar `opencode.json` y `service.json`.
  Si una variable falta, el valor queda vacío.
- **Antigravity**: skills en `~/.gemini/antigravity/skills`; `mcp_config.json`/`config.json`
  en `~/.gemini/config`. `sync.ps1` genera `~/.gemini/config/mcp_config.json` desde
  `antigravity/mcp_config.example.json` reemplazando `__VAR__` por la variable de entorno.
  Definir las variables **antes** de correr `sync.ps1` por primera vez. Si `mcp_config.json`
  ya existe, no se sobrescribe.

## OAuth / logins

Estos archivos no se versionan y hay que recrearlos en la máquina destino:

- `~/.gemini/config/plugins/*/auth.json` (Google: gsheets, gslides, gdocs, gdrive, gcalendar)
- `~/.mcp-auth/` (tokens OAuth de MCP remotos)
- `~/.dsh/.credentials.yaml`

Tras el sync, lanzar Antigravity/OpenCode y completar los logins OAuth que pidan.

## Archivos locales ignorados

`opencode.json`, `service.json`, `mcp_config.json` reales, `.env*`, `*.local.*`,
`**/auth*.json`, `**/mcp-auth.json`, `**/.credentials.yaml`, bases de datos, sesiones,
storages, projects, sidecars y `node_modules`.
