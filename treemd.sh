#!/bin/sh
# treemd — gibt einen Verzeichnisbaum als Markdown-Liste aus.
set -eu

# Deterministische Sortierung der Globs, unabhängig von der Locale.
LC_ALL=C
export LC_ALL

# Farben nur, wenn das Ziel ein Terminal ist und der Nutzer sie nicht
# abbestellt hat. $1 ist der Dateideskriptor, auf den ausgegeben wird.
BOLD='' DIM='' CYAN='' RESET=''
color_setup() {
    BOLD='' DIM='' CYAN='' RESET=''
    [ -z "${NO_COLOR:-}" ] || return 0
    [ "${TERM:-dumb}" != dumb ] || return 0
    [ -t "$1" ] || return 0
    BOLD=$(printf '\033[1m')
    DIM=$(printf '\033[2m')
    CYAN=$(printf '\033[36m')
    RESET=$(printf '\033[0m')
}

usage() {
    printf '%streemd%s — Verzeichnisbaum als Markdown\n\n' "$BOLD" "$RESET"
    printf '%sVERWENDUNG%s\n' "$BOLD" "$RESET"
    printf '  treemd.sh [-a] [-L] [-d TIEFE] [VERZEICHNIS]\n\n'
    printf '%sOPTIONEN%s\n' "$BOLD" "$RESET"
    printf '  %s-a%s         versteckte Einträge (Punktdateien) mit ausgeben\n' "$CYAN" "$RESET"
    printf '  %s-L%s         Symlinks auf Verzeichnisse verfolgen\n' "$CYAN" "$RESET"
    printf '  %s-d TIEFE%s   maximale Tiefe, 0 = unbegrenzt (Standard: 0)\n' "$CYAN" "$RESET"
    printf '  %s-h%s         diese Hilfe\n\n' "$CYAN" "$RESET"
    printf '%sOhne VERZEICHNIS wird das aktuelle Verzeichnis verwendet.%s\n' "$DIM" "$RESET"
    printf '%sSymlinks erscheinen als "name → ziel"; mit -L wird ihnen gefolgt.%s\n' "$DIM" "$RESET"
    printf '%sFarben abschalten: NO_COLOR=1.%s\n' "$DIM" "$RESET"
}

show_hidden=0
follow_links=0
max_depth=0

while getopts 'aLd:h' opt; do
    case $opt in
        a) show_hidden=1 ;;
        L) follow_links=1 ;;
        d) max_depth=$OPTARG ;;
        h) color_setup 1; usage; exit 0 ;;
        *) color_setup 2; usage >&2; exit 2 ;;
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

# Zeilenumbruch und Tabulator als Variable, damit case sie erkennen kann.
NL=$(printf '\nx'); NL=${NL%x}
TAB=$(printf '\tx'); TAB=${TAB%x}
CR=$(printf '\rx'); CR=${CR%x}

# Einen Dateinamen so ausgeben, dass Markdown ihn als Text darstellt:
# Sonderzeichen werden mit \ maskiert, Steuerzeichen (Zeilenumbruch,
# Tabulator, CR) durch Leerzeichen ersetzt, damit die Zeile eine bleibt.
# Der Schnellpfad ohne Fork deckt gewöhnliche Namen ab.
md_escape() {
    case $1 in
        *[\\\`*_\[\]\<\>\&\|\~]* | *"$NL"* | *"$TAB"* | *"$CR"*)
            printf '%s' "$1" \
                | tr '\n\r\t' '   ' \
                | sed 's/[][\`*_<>&|~\\]/\\&/g'
            ;;
        *)
            printf '%s' "$1"
            ;;
    esac
}

# md_escape in eine Variable holen, ohne dass abschließende Zeilenumbrüche
# von der Kommandosubstitution geschluckt werden.
escaped() {
    _e=$(md_escape "$1"; printf x)
    printf '%s' "${_e%x}"
}

# Physischen Pfad eines Verzeichnisses bestimmen (aufgelöste Symlinks).
# Leer, wenn es nicht betretbar ist.
physical() {
    (cd "$1" 2>/dev/null && pwd -P) || printf ''
}

# Ein Verzeichnis ausgeben und, solange die Tiefe es erlaubt, absteigen.
# Der Funktionsrumpf ist eine Subshell: so bleiben die Variablen bei der
# Rekursion getrennt.
#
# Die Einträge kommen aus Globs, nicht aus `find | sort | read` — Globs
# überstehen jedes Zeichen im Dateinamen, auch Zeilenumbrüche.
#
# $4 ist die Kette der bereits betretenen physischen Pfade; sie verhindert,
# dass -L in einem Symlink-Zyklus endlos kreist.
walk() (
    dir=$1
    indent=$2
    depth=$3
    chain=$4

    if [ "$show_hidden" -eq 1 ]; then
        set -- "$dir"/.[!.]* "$dir"/..?* "$dir"/*
    else
        set -- "$dir"/*
    fi

    for entry do
        # Kein Treffer: das Muster steht unverändert da (leeres oder
        # nicht lesbares Verzeichnis).
        [ -e "$entry" ] || [ -L "$entry" ] || continue

        name=$(escaped "${entry##*/}")
        suffix=''
        target=''

        if [ -L "$entry" ]; then
            target=$(readlink "$entry" 2>/dev/null || printf '')
            [ -z "$target" ] || suffix=" → $(escaped "$target")"
            # Ein Symlink auf ein Verzeichnis bekommt das / nur, wenn
            # das Ziel auch wirklich eines ist.
            if [ -d "$entry" ]; then
                printf '%s- %s/%s\n' "$indent" "$name" "$suffix"
            else
                printf '%s- %s%s\n' "$indent" "$name" "$suffix"
            fi
            [ "$follow_links" -eq 1 ] && [ -d "$entry" ] || continue
        elif [ -d "$entry" ]; then
            printf '%s- %s/\n' "$indent" "$name"
        else
            printf '%s- %s\n' "$indent" "$name"
            continue
        fi

        # Ab hier: Verzeichnis, in das abgestiegen werden darf.
        [ "$max_depth" -eq 0 ] || [ "$depth" -lt "$max_depth" ] || continue

        if [ ! -r "$entry" ]; then
            # Stumm bliebe es so aussehen, als wäre es leer.
            printf 'treemd: nicht lesbar, übersprungen: %s\n' "$entry" >&2
            continue
        fi

        here=$(physical "$entry")
        case "$NL$chain$NL" in
            *"$NL$here$NL"*)
                printf 'treemd: Symlink-Zyklus, nicht verfolgt: %s\n' "$entry" >&2
                continue
                ;;
        esac

        walk "$entry" "$indent  " $((depth + 1)) "$chain$NL$here"
    done
)

# Wurzel als eigene Zeile, Kinder darunter eingerückt.
printf -- '- %s/\n' "$(escaped "$(basename -- "$root")")"
walk "$root" '  ' 1 "$(physical "$root")"
