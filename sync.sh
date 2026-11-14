#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
HOME_DIR="${HOME}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=true; shift ;;
    --home) HOME_DIR="$2"; shift 2 ;;
    *) echo "Uso: $0 [--dry-run] [--home <path>]"; exit 1 ;;
  esac
done

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$REPO/.env.local" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
      k="${BASH_REMATCH[1]}"
      v="${BASH_REMATCH[2]}"
      v="${v#\"}" ; v="${v%\"}"
      v="${v#\'}" ; v="${v%\'}"
      if [[ -z "${!k:-}" ]]; then
        export "$k=$v"
      fi
    fi
  done < "$REPO/.env.local"
fi

sync_dir() {
  local src="$1" dst="$2"
  [[ -d "$src" ]] || return 0
  if $DRY_RUN; then
    echo "[dry-run] sync $src -> $dst"
    return 0
  fi
  mkdir -p "$dst"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude='node_modules' --exclude='.git' --exclude='auth.json' --exclude='*.gif' "$src/" "$dst/"
  else
    cp -r "$src/." "$dst/"
  fi
}

# 1. Skills -> 4 roots
for root in \
  "$HOME_DIR/.agents/skills" \
  "$HOME_DIR/.config/opencode/skills" \
  "$HOME_DIR/.dsh/skills" \
  "$HOME_DIR/.gemini/config/skills"; do
  sync_dir "$REPO/skills" "$root"
done

# 2. OpenCode
OC="$HOME_DIR/.config/opencode"
mkdir -p "$OC"

for v in CONTEXT7_API_KEY TESTSPRITE_API_KEY GITHUB_PAT OPENCODE_SERVICE_PASSWORD; do
  if [[ -z "${!v:-}" ]]; then
    echo "WARN: OpenCode: falta $v; el placeholder quedará vacío." >&2
  fi
done

[[ -f "$OC/opencode.json" ]] || cp "$REPO/opencode/opencode.example.json" "$OC/opencode.json"
[[ -f "$OC/service.json" ]] || cp "$REPO/opencode/service.example.json" "$OC/service.json"

for f in cli.json tui.json dcp.jsonc AGENTS.md package.json package-lock.json; do
  [[ -f "$REPO/opencode/$f" ]] && cp "$REPO/opencode/$f" "$OC/$f"
done
sync_dir "$REPO/opencode/agents" "$OC/agents"
sync_dir "$REPO/opencode/commands" "$OC/commands"
sync_dir "$REPO/opencode/plugins" "$OC/plugins"

# 3. Antigravity
AG="$HOME_DIR/.gemini/config"
mkdir -p "$AG"

[[ -f "$REPO/opencode/AGENTS.md" ]] && cp "$REPO/opencode/AGENTS.md" "$HOME_DIR/.gemini/GEMINI.md"
[[ -f "$REPO/antigravity/config.json" ]] && cp "$REPO/antigravity/config.json" "$AG/config.json"

MCP_EX="$REPO/antigravity/mcp_config.example.json"
if [[ ! -f "$AG/mcp_config.json" && -f "$MCP_EX" ]]; then
  content="$(cat "$MCP_EX")"
  for v in TESTSPRITE_API_KEY GITHUB_PAT SUPERMEMORY_TOKEN INVGATE_TOKEN; do
    val="${!v:-}"
    if [[ -n "$val" ]]; then
      content="${content//__${v}__/$val}"
    else
      echo "WARN: Antigravity: falta $v; su placeholder quedará sin reemplazar en mcp_config.json." >&2
    fi
  done
  if $DRY_RUN; then
    echo "[dry-run] generaría $AG/mcp_config.json"
  else
    printf '%s' "$content" > "$AG/mcp_config.json"
    echo "Generado $AG/mcp_config.json"
  fi
fi

sync_dir "$REPO/antigravity/plugins" "$AG/plugins"

echo "Sync completado."
