# Stand — treemd
_Zuletzt: 2026-09-16_

## Stand
`treemd.sh` läuft: POSIX sh, gibt einen Verzeichnisbaum als Markdown-Liste aus.
Optionen `-a` (versteckte Einträge), `-L` (Symlinks verfolgen), `-d TIEFE`, `-h`.
Namen werden für Markdown maskiert (D-002), Symlinks als `name → ziel` mit
Zyklusschutz (D-003), Hilfe farbig nur am Terminal (D-004). README beschreibt
Verwendung, Optionen, Beispiele und Grenzen. Alles auf `origin/main` (D-005).

## Offen
- Vorschlag (nicht beschlossen): `.gitignore` für `.DS_Store` — liegt untracked im Repo.
- Vorschlag (nicht beschlossen): CLAUDE.md mit Stack und Prüfkommandos; bisher bewusst weggelassen.
- Vorschlag (nicht beschlossen): automatisierter Testlauf statt manueller Testverzeichnisse.

## Nächster Schritt
`.gitignore` mit `.DS_Store` anlegen und einchecken.

## Halbfertig / Vorsicht
- Kein `shellcheck` auf dieser Maschine gelaufen — geprüft nur mit `sh -n` und manuellen Läufen gegen ein Testverzeichnis.
- Keine automatisierten Tests im Repo; die Testverzeichnisse lagen im Scratchpad und sind nicht erhalten.
- `.DS_Store` ist untracked und gehört nicht in Commits.
