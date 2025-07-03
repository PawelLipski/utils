function print_one_lang_stats() {
  name=$1
  ext=$2
  echo "$name files: $(git grep -Il '' -- "*$ext" | wc -l)"
  echo "$name lines: $(git grep -Il '' -- "*$ext" | xargs cat 2>/dev/null | wc -l)"
  # note that <branch>@{date} looks up reflogs, so the commits is where master was 1 week ago in the LOCAL repository
  echo "$name changes in last week: $(git diff --stat 'master@{1 week ago}' "*$ext" 2>/dev/null | tail -1)"
}

function print_lang_stats() {
  print_one_lang_stats Java .java
  print_one_lang_stats Kotlin .kt
  print_one_lang_stats Scala .scala
  print_one_lang_stats All ''
}

function print_one_lang_authorship_stats() {
  name=$1
  ext=$2
  weeks=$3
  result=$(git log --format='%ae' --since="$weeks weeks ago" "**/*$ext" | sort -u | wc -l)
  echo "People (unique author emails) who touched $name files in the last $weeks week(s): $result"
}

function print_lang_authorship_stats() {
  print_one_lang_authorship_stats Java .java 1
  print_one_lang_authorship_stats Java .java 4
  print_one_lang_authorship_stats Java .java 52
  print_one_lang_authorship_stats Kotlin .kt 1
  print_one_lang_authorship_stats Kotlin .kt 4
  print_one_lang_authorship_stats Kotlin .kt 52
  print_one_lang_authorship_stats Scala .scala 1
  print_one_lang_authorship_stats Scala .scala 4
  print_one_lang_authorship_stats Scala .scala 52
}
