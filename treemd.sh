#!/bin/sh
# treemd — gibt einen Verzeichnisbaum als Markdown-Liste aus.
set -eu

usage() {
    cat <<'EOF'
Verwendung: treemd.sh [-a] [-d TIEFE] [VERZEICHNIS]

  -a          versteckte Einträge (Punktdateien) mit ausgeben
  -d TIEFE    maximale Tiefe, 0 = unbegrenzt (Standard: 0)
  -h          diese Hilfe

Ohne VERZEICHNIS wird das aktuelle Verzeichnis verwendet.
EOF
}

show_hidden=0
max_depth=0

while getopts 'ad:h' opt; do
    case $opt in
        a) show_hidden=1 ;;
        d) max_depth=$OPTARG ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

case $max_depth in
    ''|*[!0-9]*)
        printf 'treemd: -d erwartet eine nicht-negative Zahl: %s\n' "$max_depth" >&2
        exit 2
        ;;
esac

root=${1:-.}
if [ ! -d "$root" ]; then
    printf 'treemd: kein Verzeichnis: %s\n' "$root" >&2
    exit 1
fi

# Ein Verzeichnis ausgeben und, solange die Tiefe es erlaubt, absteigen.
# Der Funktionsrumpf ist eine Subshell: so bleiben dir/indent/depth
# bei der Rekursion getrennt.
walk() (
    dir=$1
    indent=$2
    depth=$3

    if [ "$show_hidden" -eq 1 ]; then
        find "$dir" -mindepth 1 -maxdepth 1
    else
        find "$dir" -mindepth 1 -maxdepth 1 ! -name '.*'
    fi | LC_ALL=C sort | while IFS= read -r entry; do
        name=${entry##*/}
        if [ -d "$entry" ] && [ ! -L "$entry" ]; then
            printf '%s- %s/\n' "$indent" "$name"
            if [ "$max_depth" -eq 0 ] || [ "$depth" -lt "$max_depth" ]; then
                walk "$entry" "$indent  " $((depth + 1))
            fi
        else
            printf '%s- %s\n' "$indent" "$name"
        fi
    done
)

# Wurzel als eigene Zeile, Kinder darunter eingerückt.
root_name=$(basename -- "$root")
printf -- '- %s/\n' "$root_name"
walk "$root" '  ' 1
