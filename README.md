# treemd

Gibt einen Verzeichnisbaum als Markdown-Liste aus — zum Einfügen in READMEs,
Notizen oder Dokumentation.

## Verwendung

```sh
./treemd.sh [-a] [-d TIEFE] [VERZEICHNIS]
```

| Option | Bedeutung |
|---|---|
| `-a` | versteckte Einträge (Punktdateien) mit ausgeben |
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

## Hinweise

- POSIX sh, keine Abhängigkeiten außer `basename`, `tr` und `sed`.
- Verzeichnisse enden auf `/`; Symlinks auf Verzeichnisse werden nicht verfolgt.
- Namen werden für Markdown maskiert (`` ` ``, `*`, `_`, `[`, `]`, `<`, `>`,
  `&`, `|`, `~`, `\`), damit sie als Text erscheinen und nicht als Auszeichnung.
- Steuerzeichen im Namen (Zeilenumbruch, Tabulator, CR) werden zu Leerzeichen,
  damit ein Eintrag eine Zeile bleibt.
- Der Baum wird über Globs gelesen, nicht über `find | sort` — dadurch sind
  auch Namen mit Zeilenumbruch unkritisch.
- Sortierung in C-Collation (`LC_ALL=C`): versteckte Einträge zuerst,
  Großbuchstaben vor Kleinbuchstaben.
- Nicht lesbare Verzeichnisse werden übersprungen, mit einem Hinweis auf stderr.
