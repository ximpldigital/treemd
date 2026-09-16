# treemd

Ein einzelnes Script: `treemd.sh` gibt einen Verzeichnisbaum als
Markdown-Liste aus. Kein Build, keine Abhängigkeiten zu installieren.

## Stack

- POSIX sh (`#!/bin/sh`), lauffähig unter dash, bash und zsh.
- Externe Kommandos: `basename`, `readlink`, `tr`, `sed`. Keine GNU-spezifischen
  Optionen — das Script soll auch unter macOS ohne coreutils laufen.
- Die Baumausgabe geht auf stdout und ist immer unformatiertes Markdown;
  Warnungen und Farbe bleiben davon getrennt (stderr bzw. nur `-h`).

## Prüfkommandos

```sh
sh -n treemd.sh                 # Syntaxprüfung, läuft immer
shellcheck -s sh treemd.sh      # optional, auf dieser Maschine nicht installiert
./treemd.sh -h                  # Hilfe, farbig nur am Terminal
./treemd.sh -a -L docs          # Lauf gegen ein echtes Verzeichnis
```

Automatisierte Tests gibt es nicht. Geprüft wird von Hand gegen ein
Wegwerfverzeichnis mit Sonderzeichen im Namen (`a*b`, `[x](y)`, Backtick,
Backslash, Zeilenumbruch), versteckten Einträgen, Symlinks auf Datei und
Verzeichnis, kaputtem Symlink, Symlink-Zyklus und einem `chmod 000`-Verzeichnis.
Wer das Script anfasst, baut sich dieses Verzeichnis neu und prüft ohne
Optionen, mit `-a`, mit `-L` und mit `-d`.

## Geschützte Bereiche

- `docs/LOG.md` ist append-only: neue Zeilen oben, nie löschen, nie umschreiben.
- `docs/sessions/*.md` nie überschreiben — nur neue Dateien anlegen.

## Arbeitsstand

Vor Arbeit an diesem Projekt docs/STATE.md lesen, dazu den Kopf
von docs/LOG.md. Entscheidungen sind dort mit [D-xxx] markiert
und gelten, bis ein neuerer Eintrag sie als ersetzt kennzeichnet.
Nicht gegen den dokumentierten Stand arbeiten, ohne die
Abweichung zu benennen.
