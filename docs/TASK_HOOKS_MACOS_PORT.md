# TAREA — Port de hooks SDAD a bash (macOS/Linux)
# SDAD v4.3 · gap conocido documentado en CHANGELOG [4.3]
# Asignable a: dev con macOS · Estimación: 1 sesión

## Contexto (leé esto primero)

SDAD v4.3 tiene 3 hooks de Claude Code que hoy son **solo Windows/PowerShell**:
`.claude/hooks/session-start.ps1`, `pre-compact.ps1` y `session-end.ps1`.
Tu tarea es portarlos a bash (`.sh`) y probarlos en macOS, siguiendo la propia
metodología SDAD (esto es un incremento — se anuncia, se aprueba, se testea,
se registra en DECISIONS.md).

Documentación de referencia obligatoria antes de tocar nada:
- `.claude/hooks/README.md` — qué hace cada hook y sus salvaguardas
- Los 3 scripts `.ps1` — son la especificación funcional exacta del port
- https://code.claude.com/docs/en/hooks — formato de stdin JSON y exit codes

## Setup

```bash
git clone https://github.com/diegomondrik/sdad-v4.git
cd sdad-v4
git checkout -b hooks-bash-port        # NUNCA trabajar en main (regla del hooks README)
claude                                  # verificar que $sdad responde con v4.3
```

## Qué portar (la lógica es chica — espejo 1:1 de los .ps1)

| Script nuevo | Espeja a | Comportamiento requerido |
|---|---|---|
| `session-start.sh` | `session-start.ps1` | 1) Si existe `.sdad/compact_anchor.md`, emitir su contenido como `additionalContext` en el JSON de salida. 2) `git pull --ff-only` SOLO si el árbol tracked está limpio. 3) Jamás bloquear el inicio: siempre `exit 0`. |
| `pre-compact.sh` | `pre-compact.ps1` | Escribir el snapshot del anchor ([LOCK] de DECISIONS.md) a `.sdad/compact_anchor.md`. Jamás `exit 2`. Siempre `exit 0`. |
| `session-end.sh` | `session-end.ps1` | Autocommit batch SOLO de `DECISIONS.md` + `LESSON_LIBRARY.md` (whitelist — nunca código). Skip si existe `.sdad/HOLD_AUTOCOMMIT`. Sin commits vacíos. Mensaje estandarizado (copiar el de la versión .ps1). |

## Registración en settings.json (parte del diseño — pensalo antes de codear)

El `.claude/settings.json` actual invoca `powershell ...` hardcodeado, así que en Mac
los hooks ni se disparan. Tenés que resolver la registración multiplataforma.
Opciones a evaluar (decidí una y documentá por qué en DECISIONS.md):
  a) Un wrapper único por hook que detecte la plataforma y delegue al .ps1 o .sh.
  b) settings.json invoca `sh` y en Windows se usa settings.local.json para override.
  c) Otra que encuentres mejor en los docs de hooks de Claude Code.
Restricción: la solución NO puede romper el setup Windows existente de Diego.

## Lecciones que ya nos costaron caro (no las repitas)

- **L-01 (encoding):** los .ps1 son ASCII puro porque caracteres no-ASCII rompieron
  el parser DOS VECES. En bash: usá UTF-8 explícito, probá con contenido con tildes
  y guiones largos en DECISIONS.md, y verificá que el anchor no salga con mojibake.
- **PreCompact NO sobrevive a la compactación por sí solo** (verificado contra docs):
  el mecanismo durable es PreCompact-escribe-a-disco + SessionStart-reinyecta.
  No "mejores" ese diseño — es intencional.
- Los hooks de lectura (start/pre-compact) JAMÁS mutan el repo.

## Test gate (mismo estándar que el port Windows — sin esto no se mergea)

Ejecutar cada script como proceso hijo con JSON mock por stdin (mirá el formato en
los docs de hooks) y verificar:

- [ ] `session-start.sh` emite JSON válido (validar con `jq`)
- [ ] Anchor con tildes/ñ/guiones largos se reinyecta sin mojibake
- [ ] `git pull` NO corre con árbol sucio; corre solo `--ff-only` con árbol limpio
- [ ] `pre-compact.sh` escribe `.sdad/compact_anchor.md` y exit 0 siempre
- [ ] `session-end.sh` con `.sdad/HOLD_AUTOCOMMIT` presente: NO commitea
- [ ] `session-end.sh` sin hold: commitea SOLO los archivos whitelisted (probar con
      un archivo de código modificado a propósito — debe quedar fuera del commit)
- [ ] Sin cambios en whitelisted: NO crea commit vacío
- [ ] Prueba integrada: sesión real de Claude Code en un repo de prueba — abrir,
      forzar compactación, cerrar — y verificar los 3 disparos

## Cierre (disciplina SDAD)

1. Actualizar `.claude/hooks/README.md` (sección Platform) y `install.sh`
   (que descargue los .sh nuevos; hoy tiene una nota de "Windows-only" — quitarla).
2. Entrada en DECISIONS.md con la decisión de registración multiplataforma.
3. Candidato a lección si encontraste un quirk de hooks en macOS.
4. PR a main — Diego revisa y mergea. NO pushear a main directo.
