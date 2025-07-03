function _extract_file_from_zip() {
  zip_path=$1
  path_inside_zip=$2
  temp_file=$(mktemp -d)/$(basename $path_inside_zip)
  unzip -p $zip_path $path_inside_zip > $temp_file
  echo $temp_file
}

function _extract_class() {
  jar=$1
  if [[ $jar = bazel-out/* ]]; then
    jar=$(bazel_execroot)/$jar
  fi
  class_regex=$2
  class_file_path=$(zipinfo -1 $jar | grep '\.class$' | grep -E "$class_regex")
  if ! [[ $class_file_path ]]; then
    echo "No class whose path in jar matches $class_regex regex found" >&2
    return 1
  fi
  class_count=$(wc -l <<< "$class_file_path" | sed 's/^\s*//')
  if [[ $class_count -ne 1 ]]; then
    echo "Expected exactly 1 class whose path in jar matches $class_regex regex, found $class_count" >&2
    echo "$class_file_path" >&2
    return 1
  fi
  _extract_file_from_zip $jar $class_file_path
}

# e.g. print_resource_from_lib com.foo:my-lib:1.2.3 META-INF/MANIFEST.MF
function print_resource_from_lib() {
  lib=$1
  resource_path=$2
  cat "$(_extract_file_from_zip "$(_jar_for_lib $lib)" "$resource_path")"
}

# e.g. javap_from_jar /private/var/tmp/..../extensions/propagators/propagators-kt.jar MyPropagator -c
function javap_from_jar() {
  jar=$1
  class_regex=$2
  javap_opts=${*:3}
  class_file=$(_extract_class "$jar" "$class_regex") || return 1
  javap ${javap_opts[*]} "$class_file"
}

function scalap_from_jar() {
  jar=$1
  class_regex=$2
  scalap_opts=${*:3}
  class_file=$(_extract_class "$jar" "$class_regex") || return 1
  (cd "$(dirname $class_file)" && scalap ${scalap_opts[*]} "$(basename -s .class $class_file)")
}

# e.g. javap_from_lib com.google.guava:guava:20.0                          SetView
# e.g. javap_from_lib org.apache.hadoop:hadoop-mapreduce-client-core:3.2.0 'org.apache.hadoop.mapreduce.lib.input.FileInputFormat.class'
# e.g. javap_from_lib org.apache.parquet:parquet-hadoop:1.10.1             'org/apache/parquet/hadoop/ParquetWriter\$Builder'    -c
function javap_from_lib() {
  lib=$1
  class=$2
  javap_from_jar "$(_jar_for_lib $lib)" "$class" "${@:3}"
}

# e.g. scalap_from_lib org.apache.flink:flink-streaming-scala_2.11:1.12.2 'org/apache/flink/streaming/api/scala/package.class'
function scalap_from_lib() {
  lib=$1
  class=$2
  scalap_from_jar "$(_jar_for_lib $lib)" "$class" "${@:3}"
}

# e.g. cat $(bazel_execroot)/bazel-out/darwin-fastbuild/bin/.../libconfigs.jar-0.params | find_class_in_jars_from_stdin org.apache.parquet.hadoop.ParquetWriter
function find_class_in_jars_from_stdin() {
  class_regex=$1
  execroot=$(bazel_execroot)
  grep '\.jar$' | sort -u | while read -r jar; do
    found=$(_list_jar $execroot/$jar 2>/dev/null | grep -E "$class_regex")
    if [[ $found ]]; then
      echo $jar:
      echo "$found"
      echo
    fi
  done
}

function find_class_in_libs_from_stdin() {
  class_regex=$1
  grep -v '^#' | sort -u | while read -r lib; do
    found=$(list_jar_for_lib $lib | grep -E "$class_regex")
    echo "Checking $lib"
    if [[ $found ]]; then
      echo "Found match in $lib:"
      echo "$found"
      echo
    fi
  done
}

function _list_jar() {
  jar=$1
  zipinfo -1 "$jar" | sort
}

# e.g. list_jar_for_lib org.apache.parquet:parquet-hadoop:1.12.2
function list_jar_for_lib() {
  lib=$1
  _list_jar "$(_jar_for_lib $lib)"
}

# e.g. list_common_entries_in_jars_for_libs org.apache.flink:flink-connector-kafka-0.10_2.11:1.11.1 org.apache.flink:flink-connector-kafka-base_2.11:1.11.1
function list_common_entries_in_jars_for_libs() {
  comm -12 <(list_jar_for_lib $1) <(list_jar_for_lib $2)
}

function _jar_for_lib() {
  lib=$1
  coursier fetch --repository=https://us-east-1.artifactory.musta.ch/artifactory/maven --quiet --intransitive $lib | head -1
}
