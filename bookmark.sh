#!/usr/bin/env bash

# Store list directories into a text file and query like commands: pushd, popd.


# set file bookmark:
BM_FILE=~/.bookmark

# the way end program (source | command):
if [ "$0" != "$BASH_SOURCE" ]; then
  EXIT=return
else
  EXIT=exit
fi

# help:
_bm_help() {
  echo -e "
  NAME
  \tb - bookmark management
  \tc - change diretory to a bookmark

  USAGE
  \tb [option] [index | string]
  \tc [index | string]

  \tYou need source this script before use command b and c.
  \tRun this command to source this script:

  \techo \"source \$(pwd)/bookmark.sh\" >> ~/.bashrc

  \tYou can change bookmark file location by edit BM_FILE variable in this script

  OPTIONS
  \tf [file path]\t\tOverwrite bookmark file
  \ta [diretory path]\tAdd diretory to list bookmarks
  \t\t\t\tWithout any diretory path will auto get current diretory
  \tl\t\t\tList bookmark file with index
  \ti [index]\t\tGet a bookmark by index
  \tg [string]\t\tGet bookmark which match string
  \to [index | string]\tGet a bookmark by index or match string 
  \t\t\t\tIf match many bookmark, auto get first one.
  \tr [index]\t\tRemove a bookmark by index

  EXAMPLES
  \tb a /media/cdrom\tAdd a diretory to bookmark
  \tb l\t\t\tPrint list bookmarks
  \tb\t\t\tShorthand command to print list bookmarks
  \tb i 1\t\t\tGet first bookmark
  \tb 1\t\t\tShorthand command to get first bookmark
  \tb g cdrom\t\tGet bookmark which contain string \"cdrom\"
  \tb cdrom\t\t\tShorthand command to get bookmark which contain string \"cdrom\"
  \tb media.*cdrom\t\tGet bookmark which have both \"media\" and \"cdrom\" string.
  \tc 1\t\t\tChange diretory to first bookmark
  \tc cdrom\t\t\tChange diretory to bookmark match \"cdrom\" string
  "
}

# overwrite bookmark file:
_bm_overwrite_bookmark_file() {
  BM_FILE="$1"
}

# add:
_bm_add() {
  if [ -z "$1" ]; then
    echo $(pwd) >> "$BM_FILE"
  else
    echo "$1" >> "$BM_FILE"
  fi
  _bm_list
}

# list:
_bm_list() {
  awk '{print NR,$0}' "$BM_FILE"
}

# get by index:
_bm_get_by_index() {
  bookmark=$(sed "$1!d" "$BM_FILE")
  echo "$bookmark"
}

# get by grep string:
_bm_get_by_grep() {
  _bm_list | grep "$1"
}

_bm_get_one() {
  pattern='^[0-9]+$'
  if [[ "$1" =~ $pattern ]]; then
    bookmark=$(_bm_get_by_index "$1")
  else
    bookmark=$(cat "$BM_FILE" | grep -iE "$1" | head -n 1)
  fi
  echo "$bookmark"
}

_bm_change_directory() {
  bookmark=$(_bm_get_one "$1")
  if [[ ! -z "$bookmark" && -d "$bookmark" ]]; then
    cd "$bookmark"
  fi
}

# remove:
_bm_remove() {
  sed -i "$1d" "$BM_FILE"
  _bm_list
}

while test $# -ge 0; do
  case "$1" in
    f)
      shift
      _bm_overwrite_bookmark_file "$1"
      shift
      ;;
    h)
      _bm_help
      $EXIT
      ;;
    a)
      _bm_add "$2"
      $EXIT
      ;;
    l)
      _bm_list
      $EXIT
      ;;
    i)
      _bm_get_by_index "$2"
      $EXIT
      ;;
    g)
      _bm_get_by_grep "$2"
      $EXIT
      ;;
    o)
      _bm_get_one "$2"
      $EXIT
      ;;
    r)
      _bm_remove "$2"
      $EXIT
      ;;
    *)
      if [ "$0" != "$BASH_SOURCE" ]; then
        alias b="${BASH_SOURCE[0]}"
        alias c=_bm_change_directory
      else
        if [ ! -z "$1" ]; then
          _bm_get_one "$1"
        else
          _bm_list 
        fi
        EXIT=exit
      fi
      $EXIT
      ;;
  esac
done
