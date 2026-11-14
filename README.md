# agent-config

Repo privado con las configuraciones globales y skills de OpenCode y Antigravity,
sin secretos en git. Fuente única: se clona, se sincroniza y listo.

## Estructura

```
agent-config/
├─ skills/                  # 71 skills (fuente única)
├─ opencode/
│  ├─ opencode.example.json # placeholders {env:VAR}
│  ├─ service.example.json  # password {env:OPENCODE_SERVICE_PASSWORD}
│  ├─ cli.json, tui.json, dcp.jsonc, AGENTS.md
│  ├─ agents/ commands/ plugins/
│  └─ package.json, package-lock.json
├─ antigravity/
│  ├─ mcp_config.example.json # placeholders __VAR__
│  ├─ config.json             # sin secretos
│  └─ plugins/                # sin auth.json ni *.gif
├─ .env.example
├─ SECRETS.md
├─ sync.ps1
└─ .gitignore
```

`dsh/skills` no se duplica: `sync.ps1` escribe las skills también en `~/.dsh/skills`.

## Instalación

```powershell
git clone https://github.com/ignaciorevainera/opencode-antigravity-config.git ~/agent-config
cd ~/agent-config
. .\sync.ps1              # en Linux/macOS/WSL: ./sync.sh (soporta --dry-run)
cd ~/.config/opencode
npm install
# Si usas los plugins de Antigravity con dependencias Node:
# npm --prefix ~/.gemini/config/plugins/security/mcp-server install
# npm --prefix ~/.gemini/config/plugins/vercel-plugin install
```

1. Definir las variables de entorno (ver `SECRETS.md`) o copiar `.env.example` a `.env.local` **antes** del primer sync.
2. Completar logins OAuth / MCP en OpenCode y Antigravity.
3. En OpenCode: `/reload`.

## Qué hace `sync.ps1` / `sync.sh`

- Copia `skills/` a 4 raíces: `~/.agents/skills`, `~/.config/opencode/skills`,
  `~/.dsh/skills` y `~/.gemini/config/skills`.
- OpenCode: si `opencode.json` o `service.json` no existen, los crea desde los
  ejemplos. `cli.json`, `tui.json`, `dcp.jsonc`, `AGENTS.md`, `package*.json`,
  `agents/`, `commands/` y `plugins/` se sincronizan desde el repo.
- Antigravity: si `~/.gemini/config/mcp_config.json` no existe, lo genera desde el
  ejemplo reemplazando `__VAR__` con las variables de entorno. `opencode/AGENTS.md`
  se copia también a `~/.gemini/GEMINI.md` como regla global compartida. `config.json`
  y `plugins/` se sincronizan desde el repo.
- No sobrescribe archivos reales con secretos ni `auth.json`.

## Seguridad

- Nunca commitear `opencode.json`, `service.json`, `mcp_config.json` reales, `.env*`,
  `*.local.*`, `**/auth*.json`, `**/.credentials.yaml` ni bases de datos.
- Los valores van en variables de entorno o en un gestor de contraseñas.
- Detalle completo en `SECRETS.md`.
