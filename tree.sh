#!/usr/bin/env bash
# treemd — schreibt die Ordner-Hierarchie eines Verzeichnisses als Baumansicht
#
# Verwendung:
#   treemd [Optionen] [Pfad]
#
# Optionen:
#   -o DATEI      Ausgabedatei (Standard: tree.txt im Zielordner)
#   -d TIEFE      maximale Tiefe (Standard: unbegrenzt)
#   -q            nur Datei schreiben, Baum nicht im Terminal anzeigen
#   -h, --help    Hilfe anzeigen
#
# Es werden nur Ordner aufgelistet; hinter jedem Ordner steht die Anzahl
# der direkt enthaltenen Dateien, z. B. "Assets (12 Dateien)".

set -euo pipefail
shopt -s nullglob

usage() {
  cat <<'EOF'
treemd — schreibt die Ordner-Hierarchie eines Verzeichnisses als Baumansicht

VERWENDUNG
  treemd [Optionen] [Pfad]

  Ohne Pfad wird der aktuelle Ordner verwendet. Das Ergebnis landet in
  einer tree.txt im Zielordner und wird zusätzlich im Terminal angezeigt.

OPTIONEN
  -o DATEI      Ausgabedatei (Standard: tree.txt im Zielordner)
  -d TIEFE      maximale Tiefe, z. B. -d 2 für zwei Ebenen (Standard: alle)
  -q            nur Datei schreiben, Baum nicht im Terminal anzeigen
  -h, --help    diese Hilfe anzeigen

AUSGABE
  Es werden nur Ordner aufgelistet. Hinter jedem Ordner steht die Anzahl
  der direkt enthaltenen Dateien:

    Projekt A (1 Datei)
    ├── Assets (12 Dateien)
    │   └── Icons (3 Dateien)
    └── Export

  Ignoriert werden .git, node_modules und .DS_Store. macOS-Bundles
  (.key, .pptx, .app, …) zählen als Datei und werden nicht durchlaufen.

BEISPIELE
  treemd                        aktuellen Ordner erfassen
  treemd ~/Documents            anderen Ordner erfassen
  treemd -d 2                   nur die ersten zwei Ebenen
  treemd -q -o ~/struktur.txt   ohne Terminal-Ausgabe an eigenen Ort schreiben
EOF
}

output=""
max_depth=0
quiet=false
root=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) output="$2"; shift 2 ;;
    -d) max_depth="$2"; shift 2 ;;
    -q) quiet=true; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unbekannte Option: $1" >&2; usage >&2; exit 1 ;;
    *) root="$1"; shift ;;
  esac
done

root="${root:-$PWD}"
root="${root%/}"
if [[ ! -d "$root" ]]; then
  echo "Fehler: '$root' ist kein Verzeichnis" >&2
  exit 1
fi
output="${output:-$root/tree.txt}"

dir_count=0

# macOS-Bundles (Ordner, die sich wie Dateien verhalten) als Datei zählen
bundle_re='\.(key|pptx|app|band|imovielibrary|photoslibrary)$'

# Liefert "Unterordner|Dateianzahl" für ein Verzeichnis
scan() {
  local dir="$1" entry name
  subdirs=()
  files=0
  for entry in "$dir"/*; do
    name="${entry##*/}"
    case "$name" in
      .git|node_modules|.DS_Store|"${output##*/}") continue ;;
    esac
    if [[ -d "$entry" && ! "$name" =~ $bundle_re ]]; then
      subdirs+=("$entry")
    else
      files=$((files + 1))
    fi
  done
}

label() {
  local name="$1" count="$2"
  if [[ "$count" -eq 1 ]]; then
    printf '%s (1 Datei)' "$name"
  elif [[ "$count" -gt 0 ]]; then
    printf '%s (%d Dateien)' "$name" "$count"
  else
    printf '%s' "$name"
  fi
}

walk() {
  local dir="$1" prefix="$2" depth="$3"
  local subdirs files
  scan "$dir"

  local total=${#subdirs[@]} i=0 sub name connector child_prefix
  for sub in ${subdirs[@]+"${subdirs[@]}"}; do
    i=$((i + 1))
    name="${sub##*/}"
    if [[ "$i" -eq "$total" ]]; then
      connector="└── "; child_prefix="${prefix}    "
    else
      connector="├── "; child_prefix="${prefix}│   "
    fi

    scan "$sub"
    printf '%s%s%s\n' "$prefix" "$connector" "$(label "$name" "$files")" >> "$output"
    dir_count=$((dir_count + 1))

    if [[ "$max_depth" -eq 0 || "$depth" -lt "$max_depth" ]]; then
      walk "$sub" "$child_prefix" $((depth + 1))
    fi
  done
}

subdirs=()
files=0
scan "$root"
{
  printf '%s\n' "$(label "$(basename "$root")" "$files")"
} > "$output"

walk "$root" "" 1

echo "✓ $output geschrieben ($dir_count Ordner)"
if ! $quiet; then
  echo
  cat "$output"
fi
