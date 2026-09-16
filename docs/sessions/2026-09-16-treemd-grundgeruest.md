# treemd — Grundgerüst und Robustheit
_2026-09-16 · Entscheidungen: D-001, D-002, D-003_

## Entscheidungen
- D-001: Die erste Fassung las mit `find -mindepth 1 -maxdepth 1 | sort | while read`. Das ist gut sortierbar, bricht aber bei Zeilenumbruch im Dateinamen, und der portable Ausweg fehlt: `-print0` braucht `read -d`, das nicht POSIX ist. Globs kennen das Problem nicht, kosten dafür die freie Sortierung — versteckte und sichtbare Einträge müssen in zwei Mustern (`.[!.]*`, `..?*`, `*`) geholt werden und erscheinen dadurch getrennt. Mit LC_ALL=C entspricht das genau der bisherigen Reihenfolge (Punktdateien zuerst), der Bruch fällt also nicht auf. Nebenbei entfallen die Nicht-POSIX-Optionen von find.
- D-002: Maskiert wird nur, was inline tatsächlich rendert. `(` und `)` bleiben unmaskiert — ein Link entsteht ohne unmaskiertes `[` nicht, und `\(` im Namen wäre Lärm. Steuerzeichen werden ersetzt statt maskiert: eine korrekte Darstellung gibt es in einer Listenzeile nicht, ein einzeiliger Eintrag ist das kleinere Übel als eine zerrissene Liste.
- D-003: Der Zyklusschutz vergleicht physische Pfade der Vorfahrenkette, nicht Namen — ein Symlink auf `..` wird so erkannt, auch über mehrere Ebenen (getestet direkt und über `link-auf-dir/zyklus`). Die Kette wird für alle Verzeichnisse mitgeführt, nicht nur für Symlinks, weil ein Link auf einen beliebigen Vorfahren zeigen kann.

## Erkenntnisse
- Nicht lesbare Verzeichnisse sahen vorher wie leere aus. Jetzt Hinweis auf stderr, stdout bleibt reines Markdown — dieselbe Trennung wie bei den Farben (D-004).
- Getestet wurde gegen ein Verzeichnis mit `a*b`, `[link](x)`, Backtick, Backslash, `<html>`, `pipe|bar`, `tilde~`, `under_score.md`, Name mit Zeilenumbruch, `.hidden`, `..dotdot`, Leerverzeichnis, `chmod 000`-Verzeichnis, Symlink auf Datei/Verzeichnis, kaputtem Symlink und Zyklus — jeweils ohne Optionen, mit `-a`, `-L` und `-d`.

## Offene Fragen
- Soll die Ausgabe optional Größen oder Änderungsdaten enthalten? Bisher nicht gefragt, würde die Zeilenform ändern.
- Ob `.gitignore` nötig wird (`.DS_Store` liegt untracked im Repo) — bisher nicht entschieden.
