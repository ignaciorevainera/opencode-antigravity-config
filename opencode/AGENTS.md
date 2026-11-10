<!-- caveman-begin -->
Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:
- Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
- Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
- Pattern: [thing] [action] [reason]. [next step].
- Not: "Sure! I'd be happy to help you with that."
- Yes: "Bug in auth middleware. Fix:"

Switch level: /caveman lite|full|ultra|wenyan
Stop: "stop caveman" or "normal mode"

Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

Boundaries: code/commits/PRs written normal.
<!-- caveman-end -->

<!-- context7 -->
Use Context7 MCP to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service — even well-known ones like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. This includes API syntax, configuration, version migration, library-specific debugging, setup instructions, and CLI tool usage. Use even when you think you know the answer — your training data may not reflect recent changes. Prefer this over web search for library docs.

Do not use for: refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts.

## Steps

1. Always start with `resolve-library-id` using the library name and what to look up in the library's documentation, unless the user provides an exact library ID in `/org/project` format
2. Pick the best match (ID format: `/org/project`) by: exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). If results don't look right, try alternate names or queries (e.g., "next.js" not "nextjs", or rephrase the question). Use version-specific IDs when the user mentions a version
3. `query-docs` with the selected library ID and what to look up in the library's documentation (not single words), scoped to a single concept. If the question spans multiple distinct concepts (e.g. routing and auth and caching), make a separate `query-docs` call per concept with the same library ID, unless the question is about how the concepts interact — combined queries dilute ranking and return shallow results for each topic
4. Answer using the fetched docs
<!-- context7 -->

<!-- port-process-rules -->
## Port & Process Rules

**Before any command using ports 4321-4323:**
```powershell
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -in 4321,4322,4323 }
```

**If port occupied, kill fast (never WMI/CIM):**
```powershell
Get-NetTCPConnection -LocalPort <PORT> -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
```

**After starting server, poll until ready (no Start-Sleep):**
```powershell
while (-not (Test-NetConnection localhost -Port <PORT> -WarningAction SilentlyContinue).TcpTestSucceeded) { Start-Sleep -Milliseconds 500 }
```

**Never:**
- `Start-Process -WindowStyle Hidden` with node/astro/npm
- `Get-CimInstance Win32_Process` for port cleanup
- `Start-Sleep -Seconds N` as readiness check

**Dev server startup (autonomous):** Agente puede levantar dev server para tests. Reglas:
- Usar `Start-Process -FilePath "npm" -ArgumentList "run","dev","--port","<PORT>"` — sin `-WindowStyle Hidden`.
- Poll readiness con deadline 30s: `while ((Get-Date) -lt $deadline -and -not (Test-NetConnection localhost -Port <PORT>).TcpTestSucceeded) { Start-Sleep -Milliseconds 500 }`.
- Si server no arranca en 30s → throw error, reportar a usuario.
- Si puerto ya ocupado → matar proceso existente (regla arriba), esperar liberar, reintentar.
- Nunca `Start-Process -WindowStyle Hidden` — proceso huérfano sin handle.

**Concurrent projects (port collision):** Si varios proyectos/worktrees corren tests a la vez, cada uno DEBE usar un puerto único (ej. `PLAYWRIGHT_BASE_URL=http://localhost:4323`). Compartir el default (4321) con `reuseExistingServer` hace que el runner reuse el server del OTRO proyecto y testee la app equivocada → falsos positivos. Pinear puerto distinto por workspace.

**Command execution (autonomy):**
- **Never** `Select-Object -Last N` or `-First N` on long-running commands — buffers all output, agent blind until completion. Let output flow.
- **Never** `while` loops without deadline — add `$deadline = (Get-Date).AddSeconds(30)` and `if ((Get-Date) -ge $deadline) { throw "timeout" }`.
- **Never** `2>&1` on native commands in PowerShell — wraps stderr in ErrorRecord, slows pipeline. Let stderr flow or use `2>$null`.
- **Always** pass `--timeout=30000` to `npx playwright test` — prevents indefinite hangs on missing elements.
- **Verification before claim**: after starting server, poll port with 30s deadline before declaring ready.
<!-- port-process-rules -->
