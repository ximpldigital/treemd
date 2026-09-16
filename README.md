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

- POSIX sh, keine Abhängigkeiten außer `find` und `sort`.
- Verzeichnisse enden auf `/`; Symlinks auf Verzeichnisse werden nicht verfolgt.
- Noch offen: Dateinamen mit Zeilenumbruch brechen die Ausgabe, und
  Markdown-Sonderzeichen in Namen werden nicht escaped.
