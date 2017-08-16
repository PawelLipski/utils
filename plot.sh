from=a1c9e2b6
parse_codestat() {
	codestat $1 | awk "{print \$1;}" | tr "\n" " " | (cat; echo)
}
export -f parse_codestat

git log --merges --reverse --format=format:%H 70144cb9..@ | xargs -L1 -I{} bash -c "parse_codestat {}" | tee foo
gnuplot -e "plot 'foo' u (\$1/\$6) w l, '' u (\$2/\$6) w l, '' u (\$3/\$6) w l, '' u (\$4/\$6) w l, '' u (\$5/\$6) w l; pause 1000"

