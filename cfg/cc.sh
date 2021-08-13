#!/bin/bash

MODE="$1"
FILE="${2:--}"

case $MODE in
  synpwrap)
    sed -n '
        /^Running/	{ p; T }
        /^Job/		{ p; T }
	/[wW]arning/	{ s/.*/[33m&[0m/; p;T }
	/[eE]rror/	{ s/.*/[31m&[0m/; p;T }
	' "$FILE"
    ;;

  srr)
    sed -n '
    	/^@END/	{ p;T }
    	/^@/	{ s/^\(@[NWE]:\W\)\(\w*\)\W:\([^:]*\):\([^:]*\):\([^:]*\):\([^:]*\):\([^|]*\)|\(.*\)/\
			\x1\1\x2\2 \3:\4,\5-\6,\7 \x1\8\x2/ ; T no
		  s/\n//g; s/^\t*//; :no }
	/@N/	{ s/\x1/[32m/g; s/\x2/[0m/g; t done; s/^.*$/[32m&[0m/; :done p;T }
	/@W/	{ s/\x1/[33m/g; s/\x2/[0m/g; t done; s/^.*$/[33m&[0m/; :done p;T }
	/@E/	{ s/\x1/[31m/g; s/\x2/[0m/g; t done; s/^.*$/[31m&[0m/; :done p;T }
	' "$FILE"
    ;;

  mrp)
    sed -n '
    	/^Block.*undriven/	{ p;T }
    	/^Signal.*undriven/	{ p;T }
	' "$FILE"
    ;;

  edif2ngd)
    sed -n '
	/ERROR/		{ s/.*/[31m&[0m/; p;T }
	/WARNING/	{ s/.*/[33m&[0m/; p;T }
	' "$FILE"
    ;;

  ngdbuild)
    sed -n '
	/ERROR/		{ s/.*/[31m&[0m/; p;T }
	/WARNING/	{ s/.*/[33m&[0m/; p;T }
	/Loading/       { s/.*/[36m&[0m/; p;T }
	' "$FILE"
    ;;

  map)
    sed -n '
	/ERROR/		{ s/.*/[31m&[0m/; p;T }
	/WARNING/	{ s/.*/[33m&[0m/; p;T }
	/Unable/	{ s/.*/[31m&[0m/; p;T }
	/Loading/       { s/.*/[36m&[0m/; p;T }
	/^:/		{ p;T }
	' "$FILE"
    ;;

  par)
    sed -n '
	/ERROR/		{ s/.*/[31m&[0m/; p;T }
	/WARNING/	{ s/.*/[33m&[0m/; p;T }
	/Unable/	{ s/.*/[31m&[0m/; p;T }
	/Loading/       { s/.*/[36m&[0m/; p;T }
	/Signal=/	{ p;T }
	/^:/		{ p;T }
	' "$FILE"
    ;;

  bitgen)
    sed -n '
	/ERROR/		{ s/.*/[31m&[0m/; p;T }
	/WARNING/	{ s/.*/[33m&[0m/; p;T }
	/Loading/       { s/.*/[36m&[0m/; p;T }
	/^:/		{ p;T }
	' "$FILE"
    ;;

  ncdread)
    sed -n '
	/WARNING/	{ s/.*/[33m&[0m/; p;T }
	/^:/		{ p;T }
	' "$FILE"
    ;;

  ddtcmd)
    sed -n '
	/ERROR/		{ s/.*/[31m&[0m/; p;T }
	/WARNING/	{ s/.*/[33m&[0m/; p;T }
	/Loading/       { s/.*/[36m&[0m/; p;T }
	/^:/		{ p;T }
	' "$FILE"
    ;;

  *)
    echo "[31munknown cc mode $MODE[0m"
    sed '' "$FILE"
    ;;
esac