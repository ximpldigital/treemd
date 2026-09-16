# Stand — treemd
_Zuletzt: 2026-09-16_

## Stand
`treemd.sh` läuft: POSIX sh, gibt einen Verzeichnisbaum als Markdown-Liste aus.
Optionen `-a` (versteckte Einträge), `-L` (Symlinks verfolgen), `-d TIEFE`, `-h`.
Namen werden für Markdown maskiert (D-002), Symlinks als `name → ziel` mit
Zyklusschutz (D-003), Hilfe farbig nur am Terminal (D-004). README beschreibt
Verwendung, Optionen, Beispiele und Grenzen. `.gitignore` für `.DS_Store`,
CLAUDE.md mit Stack, Prüfkommandos und geschützten Bereichen. Alles auf
`origin/main` (D-005).

## Offen
- Vorschlag (nicht beschlossen): automatisierter Testlauf statt manueller Testverzeichnisse.

## Nächster Schritt
Automatisierten Testlauf aufsetzen, der das bisher manuelle Sonderzeichen- und
Symlink-Verzeichnis selbst baut und die Ausgabe gegen eine Erwartung prüft.

## Halbfertig / Vorsicht
- Kein `shellcheck` auf dieser Maschine gelaufen — geprüft nur mit `sh -n` und manuellen Läufen gegen ein Testverzeichnis.
- Keine automatisierten Tests im Repo; die Testverzeichnisse lagen im Scratchpad und sind nicht erhalten.
- `.DS_Store` ist untracked und gehört nicht in Commits.
