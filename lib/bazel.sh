function catb() {
  if [[ $1 = bazel-out/* ]]; then
    cat $(bazel_execroot)/$1
  else
    dir=${1#//}
    dir=${dir%:*}
    dir=${dir%/BUILD.bazel}
    cat $dir/BUILD.bazel
  fi
}

function vimb() {
  dir=${1#//}
  dir=${dir%:*}
  dir=${dir%/BUILD.bazel}
  vim $dir/BUILD.bazel
}

function ggrb() {
  git grep -n "$@" -- '**/BUILD.bazel'
}

function bqd() {
  target=$1
  cmd="bazel query \"deps($target)\""
  echo "$cmd"
  echo
  eval $cmd
}

function bqsp() {
  from=$1
  to=$2
  cmd="bazel query \"somepath($from, $to)\""
  echo "$cmd"
  echo
  eval $cmd
}

function bazel_execroot() {
  workspace_dir=$(bazel info workspace 2>/dev/null)
  output_base=$(bazel info output_base 2>/dev/null)
  echo "${output_base}/execroot/$(basename ${workspace_dir})"
}

# e.g. build_local_bazel && build_local_java_tools && ~/bazel/bazel-bin/src/bazel-dev build --override_repository=remote_java_tools=/tmp/java_tools ...
function build_local_bazel() {
  (
    cd ~/bazel
    bazel build //src:bazel-dev || exit 1
    echo
    echo "Now run ~/bazel/bazel-bin/src/bazel-dev <command>"
    echo
  )
}

function build_local_java_tools() {
  (
    set -e
    cd ~/bazel
    bazel build //src:bazel //src:java_tools_zip || exit 1
    rm -rf /tmp/java_tools
    mkdir -p /tmp/java_tools
    cp bazel-bin/src/java_tools.zip /tmp/java_tools/
    cd /tmp/java_tools/
    unzip java_tools.zip
    rm -f java_tools.zip
    touch WORKSPACE
    ls -l
    echo
    echo "Now pass '--override_repository=remote_java_tools=/tmp/java_tools' to you bazel command"
    echo
  )
}
