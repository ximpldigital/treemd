#!/bin/sh
# treemd — gibt einen Verzeichnisbaum als Markdown-Liste aus.
set -eu

# Deterministische Sortierung der Globs, unabhängig von der Locale.
LC_ALL=C
export LC_ALL

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

# Zeilenumbruch als Variable, damit case ihn erkennen kann.
NL=$(printf '\nx'); NL=${NL%x}
TAB=$(printf '\tx'); TAB=${TAB%x}

# Einen Dateinamen so ausgeben, dass Markdown ihn als Text darstellt:
# Sonderzeichen werden mit \ maskiert, Steuerzeichen (Zeilenumbruch,
# Tabulator, CR) durch Leerzeichen ersetzt, damit die Zeile eine bleibt.
# Der Schnellpfad ohne Fork deckt gewöhnliche Namen ab.
md_escape() {
    case $1 in
        *[\\\`*_\[\]\<\>\&\|\~]* | *"$NL"* | *"$TAB"* | *"$(printf '\r')"*)
            printf '%s' "$1" \
                | tr '\n\r\t' '   ' \
                | sed 's/[][\`*_<>&|~\\]/\\&/g'
            ;;
        *)
            printf '%s' "$1"
            ;;
    esac
}

# Ein Verzeichnis ausgeben und, solange die Tiefe es erlaubt, absteigen.
# Der Funktionsrumpf ist eine Subshell: so bleiben dir/indent/depth
# bei der Rekursion getrennt.
#
# Die Einträge kommen aus Globs, nicht aus `find | sort | read` — Globs
# überstehen jedes Zeichen im Dateinamen, auch Zeilenumbrüche.
walk() (
    dir=$1
    indent=$2
    depth=$3

    if [ "$show_hidden" -eq 1 ]; then
        set -- "$dir"/.[!.]* "$dir"/..?* "$dir"/*
    else
        set -- "$dir"/*
    fi

    for entry do
        # Kein Treffer: das Muster steht unverändert da (leeres oder
        # nicht lesbares Verzeichnis).
        [ -e "$entry" ] || [ -L "$entry" ] || continue

        name=$(md_escape "${entry##*/}"; printf x); name=${name%x}

        if [ -d "$entry" ] && [ ! -L "$entry" ]; then
            printf '%s- %s/\n' "$indent" "$name"
            if [ "$max_depth" -eq 0 ] || [ "$depth" -lt "$max_depth" ]; then
                if [ -r "$entry" ]; then
                    walk "$entry" "$indent  " $((depth + 1))
                else
                    # Stumm bliebe es so aussehen, als wäre es leer.
                    printf 'treemd: nicht lesbar, übersprungen: %s\n' \
                        "$entry" >&2
                fi
            fi
        else
            printf '%s- %s\n' "$indent" "$name"
        fi
    done
)

# Wurzel als eigene Zeile, Kinder darunter eingerückt.
root_name=$(md_escape "$(basename -- "$root")"; printf x)
printf -- '- %s/\n' "${root_name%x}"
walk "$root" '  ' 1
