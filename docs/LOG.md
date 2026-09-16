# LOG — treemd
Neueste zuerst. [D-nnn] Entscheidung · [P] Fallstrick · [R] externes Ergebnis. Nie löschen, nie umschreiben.

## 2026-09-16

- [D-001] Einträge kommen aus Shell-Globs, nicht aus `find | sort | read`, mit LC_ALL=C für die Sortierung — Globs überstehen jedes Zeichen im Dateinamen, auch Zeilenumbrüche, und die C-Collation macht die Reihenfolge locale-unabhängig (versteckte Einträge zuerst, Groß vor Klein). Verworfen: `find -print0` (`read -d` ist nicht POSIX). → docs/sessions/2026-09-16-treemd-grundgeruest.md
- [D-002] Dateinamen werden für Markdown maskiert (Backslash, Backtick sowie `* _ [ ] < > & | ~`), Steuerzeichen (LF/CR/Tab) werden zu Leerzeichen — sonst rendert `a*b` kursiv und `[x](y)` als Link, und ein Zeilenumbruch zerreißt den Listeneintrag. Ein case-Schnellpfad vermeidet den Fork nach sed/tr bei gewöhnlichen Namen. → docs/sessions/2026-09-16-treemd-grundgeruest.md
- [D-003] Symlinks erscheinen als `name → ziel` und werden nur mit `-L` verfolgt; Zyklen bricht eine mitgeführte Kette der physischen Pfade (`cd … && pwd -P`) mit Hinweis auf stderr ab. → docs/sessions/2026-09-16-treemd-grundgeruest.md
- [D-004] Farbe gibt es nur in der Hilfe (`-h`), nie im Baum — die Baumausgabe ist Markdown zum Weiterverarbeiten. Abgeschaltet bei `NO_COLOR`, `TERM=dumb` und fehlendem TTY; die Prüfung gilt dem Deskriptor, auf den ausgegeben wird (stderr beim Fehlerfall).
- [D-005] Der Stand wird direkt auf `origin/main` gepusht, ohne Feature-Branch und PR — Einzelscript, ein Autor. Das Remote hatte bereits einen GitHub-Initialcommit mit Stub-README; unsere Fassung kam per Rebase darauf und hat den Stub ersetzt.
- [P] POSIX sh kennt kein `local`: Rekursion braucht einen Subshell-Funktionsrumpf `walk() ( … )`, sonst überschreiben die inneren Aufrufe die Variablen der äußeren.
- [P] Kommandosubstitution schluckt abschließende Zeilenumbrüche — Abhilfe: `v=$(cmd; printf x); v=${v%x}`.
- [P] In einem git-worktree ist `.git` eine Datei, kein Verzeichnis; Tests, die auf `.git/` als Verzeichnis bauen, schlagen hier anders aus als im Hauptcheckout.
- [P] TTY-Verhalten lässt sich unter macOS mit `script -q /dev/null <kommando> | cat -v` prüfen; `pty.spawn` aus Python war dafür der Umweg.
- [P] shellcheck ist auf dieser Maschine nicht installiert; geprüft wurde nur mit `sh -n` und manuellen Läufen.
