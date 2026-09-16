# treemd

Gibt einen Verzeichnisbaum als Markdown-Liste aus — zum Einfügen in READMEs,
Notizen oder Dokumentation.

## Verwendung

```sh
./treemd.sh [-a] [-L] [-d TIEFE] [VERZEICHNIS]
```

| Option | Bedeutung |
|---|---|
| `-a` | versteckte Einträge (Punktdateien) mit ausgeben |
| `-L` | Symlinks auf Verzeichnisse verfolgen |
| `-d TIEFE` | maximale Tiefe, `0` = unbegrenzt (Standard) |
| `-h` | Hilfe |

Ohne `VERZEICHNIS` wird das aktuelle Verzeichnis verwendet.

## Beispiel

```sh
$ ./treemd.sh docs
- docs/
  - LOG.md
  - STATE.md
  - sessions/
```

Symlinks werden als `name → ziel` ausgewiesen; zeigt der Link auf ein
Verzeichnis, steht zusätzlich ein `/` hinter dem Namen:

```sh
$ ./treemd.sh beispiel
- beispiel/
  - echt/
    - datei.txt
  - kaputter-link → nirgendwo
  - link-auf-dir/ → echt
```

Ohne `-L` bleibt es bei dieser einen Zeile, mit `-L` wird in das Ziel
abgestiegen. Symlink-Zyklen werden erkannt und mit einem Hinweis auf stderr
abgebrochen.

## Hinweise

- POSIX sh, keine Abhängigkeiten außer `basename`, `readlink`, `tr` und `sed`.
- Verzeichnisse enden auf `/`; Symlinks werden nur mit `-L` verfolgt.
- `-h` gibt die Hilfe farbig aus, sofern die Ausgabe auf einem Terminal landet.
  Abschalten mit `NO_COLOR=1` oder `TERM=dumb`; in einer Pipe bleibt sie ohnehin
  ohne Escape-Sequenzen. Der Baum selbst ist immer unformatiertes Markdown.
- Namen werden für Markdown maskiert (`` ` ``, `*`, `_`, `[`, `]`, `<`, `>`,
  `&`, `|`, `~`, `\`), damit sie als Text erscheinen und nicht als Auszeichnung.
- Steuerzeichen im Namen (Zeilenumbruch, Tabulator, CR) werden zu Leerzeichen,
  damit ein Eintrag eine Zeile bleibt.
- Der Baum wird über Globs gelesen, nicht über `find | sort` — dadurch sind
  auch Namen mit Zeilenumbruch unkritisch.
- Sortierung in C-Collation (`LC_ALL=C`): versteckte Einträge zuerst,
  Großbuchstaben vor Kleinbuchstaben.
- Nicht lesbare Verzeichnisse werden übersprungen, mit einem Hinweis auf stderr.
